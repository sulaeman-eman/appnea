import { Component, type ErrorInfo, type ReactNode } from 'react'

interface Props {
  children: ReactNode
  /** Changing this resets the boundary, so navigating away clears a crash. */
  resetKey: string
}

interface State {
  error: Error | null
  resetKey: string
}

/**
 * Stops one broken page from taking the whole app down.
 *
 * Without this, a render-time throw unmounts everything including the header,
 * and the visitor is left with a blank screen and no way out except a manual
 * reload. With it they keep the navigation and can move on.
 */
export default class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { error: null, resetKey: props.resetKey }
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    return { error }
  }

  static getDerivedStateFromProps(props: Props, state: State): Partial<State> | null {
    if (props.resetKey !== state.resetKey) {
      return { error: null, resetKey: props.resetKey }
    }
    return null
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('[appnea] page crashed:', error, info.componentStack)
  }

  render() {
    if (this.state.error) {
      return (
        <div className="state error">
          <p>This page hit an error and could not be displayed.</p>
          <p>Use the navigation above to carry on, or reload to try again.</p>
        </div>
      )
    }

    return this.props.children
  }
}
