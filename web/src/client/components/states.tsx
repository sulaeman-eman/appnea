export function Loading({ what = 'page' }: { what?: string }) {
  return <div className="state">Loading {what}…</div>
}

export function ErrorState({ message }: { message: string }) {
  return (
    <div className="state error">
      <p>{message}</p>
      <p>Try reloading — if it keeps happening the API may be down.</p>
    </div>
  )
}

export function Empty({ message }: { message: string }) {
  return <div className="state">{message}</div>
}
