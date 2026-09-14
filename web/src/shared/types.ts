// Mirrors the Blueprinter serializers in backend/app/blueprints.
// Keys are camelCase because Blueprinter::CamelCaseTransformer rewrites them.

export type Agency = 'aida' | 'ssi' | 'molchanovs'
export type ScheduleStatus = 'open' | 'full' | 'cancelled' | 'done'

export interface InstructorSummary {
  id: number
  name: string
  certifications: string[]
  photoUrl: string | null
}

export interface Instructor extends InstructorSummary {
  bio: string
}

export interface Course {
  id: number
  slug: string
  title: string
  agency: Agency
  level: string
  depthTargetM: number | null
  durationDays: number
  priceCents: number
  currency: string
  summary: string
  coverImageUrl: string | null
}

export interface Schedule {
  id: number
  startDate: string
  endDate: string
  capacity: number
  seatsTaken: number
  seatsAvailable: number
  status: ScheduleStatus
  instructor: InstructorSummary | null
}

export interface CourseDetail extends Course {
  description: string
  schedules: Schedule[]
}

export interface ScheduleWithCourse extends Schedule {
  courseId: number
  course: Course
}

export interface Trip {
  id: number
  slug: string
  title: string
  destination: string
  startDate: string
  endDate: string
  capacity: number
  priceCents: number
  currency: string
  summary: string
  coverImageUrl: string | null
}

export interface TripDetail extends Trip {
  description: string
}

export interface Article {
  id: number
  slug: string
  title: string
  excerpt: string
  category: string
  publishedAt: string
  coverImageUrl: string | null
}

export interface ArticleDetail extends Article {
  body: string
}

export interface Meta {
  page: number
  count: number
}

export type Role = 'guest' | 'student' | 'instructor' | 'admin'

export interface User {
  id: number
  name: string
  email: string
  role: Role
}

export type BookingStatus = 'pending' | 'confirmed' | 'cancelled'

export interface Booking {
  id: number
  participants: number
  status: BookingStatus
  totalCents: number
  notes: string
  createdAt: string
  schedule: ScheduleWithCourse
}
