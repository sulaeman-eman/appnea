# Idempotent seed data for development. Safe to run repeatedly.

admin = User.find_or_initialize_by(email: "admin@appnea.test")
admin.assign_attributes(name: "Appnea Admin", role: :admin)
admin.password = "changeme123" if admin.new_record?
admin.save!

student = User.find_or_initialize_by(email: "student@appnea.test")
student.assign_attributes(name: "Rina Putri", role: :student)
student.password = "changeme123" if student.new_record?
student.save!

instructors = [
  { name: "Bagus Wirawan", display_order: 1, bio: "AIDA instructor based in Amed. Ten years of teaching, constant weight to 72 m.",
    certifications: [ "AIDA Instructor", "SSI Level 3", "EFR Instructor" ] },
  { name: "Maya Larasati", display_order: 2, bio: "Molchanovs instructor focused on breath-hold technique and safety.",
    certifications: [ "Molchanovs Instructor", "AIDA 4", "Rescue Diver" ] }
].map do |attrs|
  Instructor.find_or_create_by!(name: attrs[:name]) { |i| i.assign_attributes(attrs) }
end

courses = [
  { slug: "aida-2", title: "AIDA 2 Freediver", agency: :aida, level: "Level 1", depth_target_m: 20,
    duration_days: 3, price_cents: 450_000_00,
    summary: "Your first certification. Learn breath-hold technique, equalisation, and buddy safety.",
    description: "A three-day course covering freediving theory, static and dynamic apnea in confined water, and depth sessions to 20 m. No prior experience required.",
    published: true },
  { slug: "aida-3", title: "AIDA 3 Advanced Freediver", agency: :aida, level: "Level 2", depth_target_m: 30,
    duration_days: 4, price_cents: 650_000_00,
    summary: "Free immersion and constant weight to 30 m, with deep rescue technique.",
    description: "Builds on AIDA 2 with mouthfill equalisation, free immersion, and rescue from 30 m. Requires AIDA 2 or equivalent.",
    published: true },
  { slug: "aida-4", title: "AIDA 4 Master Freediver", agency: :aida, level: "Level 3", depth_target_m: 40,
    duration_days: 5, price_cents: 900_000_00,
    summary: "Depth to 40 m, advanced equalisation, and full rescue competency.",
    description: "The final recreational level. Five days covering mouthfill refinement, variable weight, and rescue from 40 m.",
    published: true },
  { slug: "molchanovs-wave-1", title: "Molchanovs Wave 1", agency: :molchanovs, level: "Wave 1", depth_target_m: 20,
    duration_days: 3, price_cents: 500_000_00,
    summary: "Molchanovs entry level with a structured training programme to follow afterwards.",
    description: "Covers the Molchanovs base training system, dry and wet apnea drills, and depth to 20 m.",
    published: true }
].map do |attrs|
  Course.find_or_create_by!(slug: attrs[:slug]) { |c| c.assign_attributes(attrs) }
end

courses.each_with_index do |course, index|
  3.times do |n|
    start_date = Date.current + (index * 7) + (n * 14) + 7
    Schedule.find_or_create_by!(course: course, start_date: start_date) do |s|
      s.instructor = instructors[(index + n) % instructors.size]
      s.end_date = start_date + course.duration_days - 1
      s.capacity = 4
      s.status = :open
    end
  end
end

trips = [
  { slug: "nusa-penida-fun-dive", title: "Nusa Penida Fun Dive", destination: "Nusa Penida, Bali",
    start_date: Date.current + 21, end_date: Date.current + 22, capacity: 8, price_cents: 1_500_000_00,
    summary: "Two days of guided fun diving at Manta Point and Crystal Bay.",
    description: "For certified freedivers. Boat, guide, and weights included. Manta encounters are common between April and October.",
    published: true },
  { slug: "amed-depth-camp", title: "Amed Depth Camp", destination: "Amed, Bali",
    start_date: Date.current + 45, end_date: Date.current + 50, capacity: 6, price_cents: 4_200_000_00,
    summary: "Six days of coached depth training on the Amed wall.",
    description: "Daily line sessions with video review, dry training, and a personalised progression plan. AIDA 3 or equivalent required.",
    published: true }
]
trips.each { |attrs| Trip.find_or_create_by!(slug: attrs[:slug]) { |t| t.assign_attributes(attrs) } }

articles = [
  { slug: "equalisation-for-beginners", title: "Equalisation for Beginners", category: "technique",
    excerpt: "Frenzel, Valsalva, and why the one you learned scuba diving will stall you at 12 m.",
    body: "Most new freedivers arrive using Valsalva, which stops working once the chest compresses. This article walks through isolating the tongue and soft palate to perform a Frenzel, plus dry drills you can practise at home.",
    published_at: 5.days.ago },
  { slug: "freediving-safety-never-alone", title: "Never Dive Alone", category: "safety",
    excerpt: "Shallow water blackout is survivable with a trained buddy and fatal without one.",
    body: "A blackout is not a dramatic event from the surface — the diver simply stops moving. This article covers buddy protocols, the 30-second surface watch, and how to perform a rescue and recovery breath.",
    published_at: 2.days.ago },
  { slug: "what-to-pack-bali", title: "What to Pack for a Bali Freediving Trip", category: "travel",
    excerpt: "Wetsuit thickness, fin bags, and the one thing everyone forgets.",
    body: "Water in Bali sits between 26 and 29 degrees for most of the year, so a 3 mm suit is usually enough. Bring reef-safe sunscreen, a nose clip if you train no-fins, and spare mask straps.",
    published_at: nil }
]
articles.each { |attrs| Article.find_or_create_by!(slug: attrs[:slug]) { |a| a.assign_attributes(attrs) } }

puts "Seeded: #{User.count} users, #{Instructor.count} instructors, #{Course.count} courses, " \
     "#{Schedule.count} schedules, #{Trip.count} trips, #{Article.count} articles"
