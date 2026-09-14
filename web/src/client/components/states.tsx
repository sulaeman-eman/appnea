import { useLocale } from '../locale'

export function Loading({ what }: { what?: string }) {
  const { t } = useLocale()
  return <div className="state">{t('state.loading')}{what ? ` ${what}` : ''}...</div>
}

export function ErrorState({ message }: { message: string }) {
  const { t } = useLocale()

  return (
    <div className="state error">
      <p>{message}</p>
      <p>{t('state.errorRetry')}</p>
    </div>
  )
}

export function Empty({ message }: { message: string }) {
  return <div className="state">{message}</div>
}
