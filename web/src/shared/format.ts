export function formatPrice(cents: number, currency: string): string {
  const amount = cents / 100
  if (currency === 'IDR') {
    return `Rp ${amount.toLocaleString('id-ID', { maximumFractionDigits: 0 })}`
  }
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount)
}

export function formatDateRange(start: string, end: string): string {
  const startDate = new Date(`${start}T00:00:00`)
  const endDate = new Date(`${end}T00:00:00`)
  const month = { month: 'short' } as const
  const sameMonth = startDate.getMonth() === endDate.getMonth() && startDate.getFullYear() === endDate.getFullYear()

  const startLabel = `${startDate.getDate()} ${startDate.toLocaleString('en-GB', month)}`
  const endLabel = sameMonth
    ? `${endDate.getDate()} ${endDate.toLocaleString('en-GB', month)}`
    : `${endDate.getDate()} ${endDate.toLocaleString('en-GB', month)}`

  return `${sameMonth ? startDate.getDate() : startLabel} – ${endLabel} ${endDate.getFullYear()}`
}

export function formatDate(value: string): string {
  return new Date(value).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })
}

export const AGENCY_LABEL: Record<string, string> = {
  aida: 'AIDA',
  ssi: 'SSI',
  molchanovs: 'Molchanovs',
}
