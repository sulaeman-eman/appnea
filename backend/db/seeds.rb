require Rails.root.join("lib/seeds/placeholder_image")

# Idempotent development seed data. Safe to run repeatedly.
#
# English lives in the base columns; `translations` carries the Indonesian
# overrides. Anything left untranslated falls back to English at render time,
# which is why some rows are deliberately only partly translated.

def upsert!(klass, find_by, attributes)
  record = klass.find_or_initialize_by(find_by)
  record.assign_attributes(attributes)
  record.save!
  record
end

def attach_cover!(record, seed)
  return if record.cover_image.attached?

  record.cover_image.attach(
    io: StringIO.new(Seeds::PlaceholderImage.jpeg(seed: seed)),
    filename: "#{seed}.jpg",
    content_type: "image/jpeg"
  )
end

# ---------------------------------------------------------------- users

admin = User.find_or_initialize_by(email: "admin@appnea.test")
admin.assign_attributes(name: "Appnea Admin", role: :admin)
admin.password = "changeme123" if admin.new_record?
admin.save!

student = User.find_or_initialize_by(email: "student@appnea.test")
student.assign_attributes(name: "Rina Putri", role: :student)
student.password = "changeme123" if student.new_record?
student.save!

# ---------------------------------------------------------- instructors

instructors = [
  {
    name: "Bagus Wirawan",
    display_order: 1,
    certifications: [ "AIDA Instructor", "SSI Level 3 Instructor", "EFR Instructor" ],
    bio: "Bagus has taught on the Amed wall since 2016 and holds a personal best of 72 m " \
         "constant weight. He teaches equalisation the slow way — dry drills first, depth " \
         "second — which is why his students rarely stall at 20 m."
  },
  {
    name: "Maya Larasati",
    display_order: 2,
    certifications: [ "Molchanovs Instructor", "AIDA 4", "Rescue Diver" ],
    bio: "Maya came to freediving from competitive swimming and focuses on breath-hold " \
         "technique and CO2 tolerance. She runs the dry training sessions and handles " \
         "safety briefings for every depth camp."
  }
].map do |attrs|
  instructor = upsert!(Instructor, { name: attrs[:name] }, attrs)

  unless instructor.photo.attached?
    instructor.photo.attach(
      io: StringIO.new(Seeds::PlaceholderImage.jpeg(seed: attrs[:name], width: 1200, height: 1200)),
      filename: "#{attrs[:name].parameterize}.jpg",
      content_type: "image/jpeg"
    )
  end

  instructor
end

# -------------------------------------------------------------- courses

courses = [
  {
    slug: "aida-2",
    title: "AIDA 2 Freediver",
    agency: :aida,
    level: "Beginner",
    depth_target_m: 20,
    duration_days: 3,
    price_cents: 450_000_00,
    published: true,
    summary: "Your first certification. Breath-hold technique, equalisation, and the buddy " \
             "system that keeps freediving safe.",
    description: <<~TEXT,
      Three days, no prior experience needed. Day one is theory and dry training: how the
      mammalian dive reflex works, why hyperventilation is dangerous, and how to perform a
      Frenzel equalisation on land before you ever try it underwater.

      Day two moves to confined water for static and dynamic apnea. Most people are surprised
      by their own numbers here — a two-minute static breath-hold is normal by the end of the
      session, and it comes from relaxation rather than lung capacity.

      Day three is open water on the line, working towards 20 m constant weight. You will also
      learn and practise a rescue from that depth, because a certification that does not include
      getting your buddy up is not worth carrying.
    TEXT
    translations: {
      "id" => {
        "title" => "AIDA 2 Freediver",
        "level" => "Pemula",
        "summary" => "Sertifikasi pertamamu. Teknik menahan napas, ekualisasi, dan sistem buddy " \
                     "yang bikin freediving tetap aman.",
        "description" => <<~TEXT
          Tiga hari, tanpa perlu pengalaman sebelumnya. Hari pertama teori dan latihan kering:
          cara kerja mammalian dive reflex, kenapa hiperventilasi berbahaya, dan cara melakukan
          ekualisasi Frenzel di darat sebelum kamu mencobanya di dalam air.

          Hari kedua pindah ke kolam untuk static dan dynamic apnea. Kebanyakan orang kaget sama
          angkanya sendiri di sesi ini — static dua menit itu normal di akhir sesi, dan itu datang
          dari relaksasi, bukan dari kapasitas paru-paru.

          Hari ketiga di laut terbuka, latihan di tali menuju 20 m constant weight. Kamu juga akan
          belajar dan mempraktikkan rescue dari kedalaman itu, karena sertifikasi yang tidak
          mengajarkan cara mengangkat buddy-mu tidak layak dibawa pulang.
        TEXT
      }
    }
  },
  {
    slug: "aida-3",
    title: "AIDA 3 Advanced Freediver",
    agency: :aida,
    level: "Intermediate",
    depth_target_m: 30,
    duration_days: 4,
    price_cents: 650_000_00,
    published: true,
    summary: "Free immersion and constant weight to 30 m, mouthfill equalisation, and rescue " \
             "from depth.",
    description: <<~TEXT,
      AIDA 3 is where most divers hit their first real wall, and it is almost always equalisation
      rather than breath-hold. Four days are spent largely on mouthfill: taking a charge of air
      into the mouth before the chest compresses, then managing it down.

      You will also learn free immersion — pulling down the line without fins — which strips away
      technique problems and shows you exactly how relaxed you actually are.

      The course finishes with a full rescue from 30 m, including bringing an unresponsive diver to
      the surface and delivering rescue breaths. AIDA 2 or an equivalent certification is required.
    TEXT
    translations: {
      "id" => {
        "level" => "Menengah",
        "summary" => "Free immersion dan constant weight sampai 30 m, ekualisasi mouthfill, dan " \
                     "rescue dari kedalaman.",
        "description" => <<~TEXT
          AIDA 3 itu titik di mana kebanyakan penyelam ketemu tembok pertamanya, dan hampir selalu
          soal ekualisasi, bukan tahan napas. Empat hari dihabiskan sebagian besar untuk mouthfill:
          mengambil cadangan udara ke mulut sebelum dada terkompresi, lalu mengelolanya ke bawah.

          Kamu juga akan belajar free immersion — turun menarik tali tanpa fin — yang membuang
          semua masalah teknik dan menunjukkan seberapa rileks kamu sebenarnya.

          Kursus ditutup dengan rescue penuh dari 30 m, termasuk membawa penyelam tak sadarkan diri
          ke permukaan dan memberi rescue breath. Wajib punya AIDA 2 atau setara.
        TEXT
      }
    }
  },
  {
    slug: "aida-4",
    title: "AIDA 4 Master Freediver",
    agency: :aida,
    level: "Advanced",
    depth_target_m: 40,
    duration_days: 5,
    price_cents: 900_000_00,
    published: true,
    summary: "Depth to 40 m, refined mouthfill, variable weight, and full rescue competency.",
    description: <<~TEXT,
      The last recreational level, and the one that takes the longest to earn. Five days on
      refining mouthfill volume and timing, reverse packing, and holding a relaxed body position
      through the freefall.

      Variable weight training is introduced as a way to build depth adaptation without the effort
      of a full constant weight dive, which matters when your equalisation is the limiting factor
      rather than your breath-hold.

      Rescue is examined from 40 m. Most people need more than five days to be comfortable at this
      depth — the certification is valid whenever you reach the standard, not on a fixed schedule.
    TEXT
    translations: {
      "id" => {
        "level" => "Mahir",
        "summary" => "Kedalaman sampai 40 m, mouthfill yang lebih halus, variable weight, dan " \
                     "kemampuan rescue penuh."
      }
    }
  },
  {
    slug: "molchanovs-wave-1",
    title: "Molchanovs Wave 1",
    agency: :molchanovs,
    level: "Beginner",
    depth_target_m: 20,
    duration_days: 3,
    price_cents: 500_000_00,
    published: true,
    summary: "Entry level with a structured training programme you keep following after the " \
             "course ends.",
    description: <<~TEXT,
      Wave 1 covers the same ground as an entry-level certification but hands you the Molchanovs
      base training system to take home: a written progression of dry and wet apnea sessions you
      run yourself, week by week.

      That is the real difference. Most people finish a first course, dive twice more that year,
      and lose everything. A structured programme is what turns three days into a habit.

      Three days of theory, pool work, and depth sessions to 20 m, plus onboarding into the
      Molchanovs training app and community.
    TEXT
    translations: {
      "id" => {
        "level" => "Pemula",
        "summary" => "Level dasar dengan program latihan terstruktur yang tetap kamu ikuti " \
                     "setelah kursus selesai."
      }
    }
  }
].map do |attrs|
  course = upsert!(Course, { slug: attrs[:slug] }, attrs)
  attach_cover!(course, attrs[:slug])
  course
end

# ------------------------------------------------------------ schedules

courses.each_with_index do |course, index|
  3.times do |n|
    start_date = Date.current + (index * 7) + (n * 14) + 7

    Schedule.find_or_create_by!(course: course, start_date: start_date) do |schedule|
      schedule.instructor = instructors[(index + n) % instructors.size]
      schedule.end_date = start_date + course.duration_days - 1
      schedule.capacity = 4
      schedule.status = :open
    end
  end
end

# ---------------------------------------------------------------- trips

[
  {
    slug: "nusa-penida-fun-dive",
    title: "Nusa Penida Fun Dive",
    destination: "Nusa Penida, Bali",
    start_date: Date.current + 21,
    end_date: Date.current + 22,
    capacity: 8,
    price_cents: 1_500_000_00,
    published: true,
    summary: "Two days of guided fun diving at Manta Point and Crystal Bay.",
    description: <<~TEXT,
      For certified freedivers who want to dive rather than train. Two days, two sites, a boat and
      a guide who knows where the mantas actually are on the day rather than where the brochure
      says they should be.

      Manta Point is a cleaning station in 8 to 15 m of water, so the diving is relaxed and the
      encounters are long. Crystal Bay is deeper and colder, with a thermocline that can drop the
      temperature by six degrees in a metre.

      Boat, guide, weights, and lunch included. Bring your own mask, fins, and a 3 mm suit.
    TEXT
    translations: {
      "id" => {
        "destination" => "Nusa Penida, Bali",
        "summary" => "Dua hari fun diving berpemandu di Manta Point dan Crystal Bay.",
        "description" => <<~TEXT
          Untuk penyelam bersertifikat yang mau menyelam, bukan latihan. Dua hari, dua spot, kapal
          dan pemandu yang tahu di mana manta-nya benar-benar ada hari itu, bukan di mana brosur
          bilang seharusnya ada.

          Manta Point itu cleaning station di kedalaman 8 sampai 15 m, jadi menyelamnya santai dan
          perjumpaannya lama. Crystal Bay lebih dalam dan lebih dingin, dengan termoklin yang bisa
          menurunkan suhu enam derajat dalam satu meter.

          Kapal, pemandu, pemberat, dan makan siang termasuk. Bawa masker, fin, dan wetsuit 3 mm
          sendiri.
        TEXT
      }
    }
  },
  {
    slug: "amed-depth-camp",
    title: "Amed Depth Camp",
    destination: "Amed, Bali",
    start_date: Date.current + 45,
    end_date: Date.current + 50,
    capacity: 6,
    price_cents: 4_200_000_00,
    published: true,
    summary: "Six days of coached depth training on the Amed wall, with video review.",
    description: <<~TEXT,
      A training camp, not a course — you already have the certification, this is about adding
      depth without adding risk.

      Two line sessions a day with a coach on the platform, filmed from below so you can see your
      own duck dive and freefall rather than guess at them. Dry training and stretching in the
      afternoon, video review in the evening.

      Group size is capped at six so nobody spends the morning waiting for the line. AIDA 3 or
      equivalent required, and you should be comfortable at 25 m before you arrive.
    TEXT
    translations: {
      "id" => {
        "summary" => "Enam hari latihan kedalaman dengan pelatih di dinding Amed, plus review video."
      }
    }
  }
].each do |attrs|
  trip = upsert!(Trip, { slug: attrs[:slug] }, attrs)
  attach_cover!(trip, attrs[:slug])
end

# ------------------------------------------------------------- articles

[
  {
    slug: "equalisation-for-beginners",
    title: "Equalisation for Beginners",
    category: "technique",
    published_at: 12.days.ago,
    excerpt: "Frenzel, Valsalva, and why the method you learned scuba diving will stall you at 12 m.",
    body: <<~TEXT,
      Almost every new freediver arrives using Valsalva — pushing air up from the chest by tensing
      the abdomen. It works fine on scuba, where you stay shallow enough that the chest still has
      air to give. In freediving it stops working somewhere between 10 and 15 m, and no amount of
      pushing harder will fix it.

      The replacement is Frenzel. Instead of the chest, you use the tongue as a piston: air is held
      in the mouth, the soft palate and vocal folds are closed, and the back of the tongue pushes
      that trapped air into the eustachian tubes. The chest is not involved at all, which is exactly
      why it keeps working as you go deeper.

      Learn it dry. Pinch your nose, make a hard "K" sound and freeze there — that is your tongue in
      roughly the right place. Then say "T" and hold — that is the tip. Moving between the two while
      the nose is pinched is the whole movement.

      The mistake people make is trying to learn this on the line, cold, upside down, with a coach
      watching. Do it on the sofa for two weeks first.
    TEXT
    translations: {
      "id" => {
        "title" => "Ekualisasi untuk Pemula",
        "excerpt" => "Frenzel, Valsalva, dan kenapa cara yang kamu pelajari waktu scuba akan " \
                     "mentok di 12 m.",
        "body" => <<~TEXT
          Hampir semua freediver pemula datang dengan Valsalva — mendorong udara dari dada dengan
          mengencangkan perut. Cara ini aman-aman saja di scuba, di mana kamu tetap cukup dangkal
          sehingga dada masih punya udara untuk diberikan. Di freediving, cara ini berhenti bekerja
          di sekitar 10 sampai 15 m, dan mendorong lebih keras tidak akan menolong.

          Penggantinya adalah Frenzel. Alih-alih dada, kamu memakai lidah sebagai piston: udara
          ditahan di mulut, langit-langit lunak dan pita suara ditutup, lalu pangkal lidah mendorong
          udara yang terperangkap itu ke saluran eustachius. Dada sama sekali tidak terlibat, dan
          justru itu sebabnya cara ini tetap bekerja makin dalam.

          Pelajari di darat. Jepit hidung, bunyikan "K" yang keras lalu berhenti di situ — itu posisi
          lidahmu kira-kira sudah benar. Lalu bunyikan "T" dan tahan — itu ujungnya. Bergerak di
          antara keduanya sambil hidung dijepit, itulah seluruh gerakannya.

          Kesalahan yang sering terjadi adalah mencoba mempelajari ini di tali, kedinginan, terbalik,
          sambil ditonton pelatih. Latih di sofa dulu selama dua minggu.
        TEXT
      }
    }
  },
  {
    slug: "freediving-safety-never-alone",
    title: "Never Dive Alone",
    category: "safety",
    published_at: 5.days.ago,
    excerpt: "Shallow water blackout is survivable with a trained buddy and fatal without one.",
    body: <<~TEXT,
      A blackout is not dramatic from the surface. There is no thrashing and no shout. The diver
      simply stops moving, and if nobody is watching at that moment, they sink.

      It usually happens in the last few metres of the ascent, when pressure drops fast and the
      oxygen already in the blood is no longer enough. The diver often feels fine right up until
      they do not — which is why "I would notice" is not a plan.

      The protocol is unglamorous and it works. One diver down, one diver watching, every time. The
      safety diver meets the diver at 10 m and ascends alongside them. On the surface, the diver
      stays watched for a full 30 seconds after the dive, hand on the shoulder, face clear of the
      water.

      If a blackout happens: keep the airway out of the water, remove the mask, blow across the eyes
      and mouth and talk to them. Most divers start breathing within seconds. Every certification we
      teach examines this, and none of it is optional.
    TEXT
    translations: {
      "id" => {
        "title" => "Jangan Pernah Menyelam Sendirian",
        "excerpt" => "Shallow water blackout bisa diselamatkan kalau ada buddy terlatih, dan fatal " \
                     "kalau tidak ada.",
        "body" => <<~TEXT
          Blackout tidak terlihat dramatis dari permukaan. Tidak ada gerakan meronta, tidak ada
          teriakan. Penyelam hanya berhenti bergerak, dan kalau tidak ada yang memperhatikan saat
          itu, dia tenggelam.

          Biasanya terjadi di beberapa meter terakhir saat naik, ketika tekanan turun cepat dan
          oksigen yang tersisa di darah sudah tidak cukup. Penyelam sering merasa baik-baik saja
          sampai detik terakhir — itulah kenapa "nanti juga kelihatan" bukan sebuah rencana.

          Protokolnya tidak keren tapi berhasil. Satu turun, satu mengawasi, setiap kali. Safety
          diver menjemput di 10 m dan naik bersama. Di permukaan, penyelam diawasi penuh selama 30
          detik setelah menyelam, tangan di bahu, wajah bebas dari air.

          Kalau blackout terjadi: jaga jalan napas tetap di atas air, lepas masker, tiup wajah dan
          mulutnya, dan ajak bicara. Kebanyakan penyelam mulai bernapas dalam hitungan detik. Semua
          sertifikasi yang kami ajarkan menguji ini, dan tidak ada bagian yang opsional.
        TEXT
      }
    }
  },
  {
    slug: "what-to-pack-bali",
    title: "What to Pack for a Bali Freediving Trip",
    category: "travel",
    published_at: 2.days.ago,
    excerpt: "Wetsuit thickness, fin bags, and the one thing everyone forgets.",
    body: <<~TEXT,
      Water in Bali sits between 26 and 29 degrees for most of the year, so a 3 mm open-cell suit is
      right for almost everyone. Crystal Bay is the exception — the thermocline there can put you in
      22 degree water without warning, and a hood is worth the space.

      Long fins do not fit in a normal suitcase. A dedicated fin bag is cheaper than replacing a
      cracked blade, and most airlines take it as a second checked item without argument.

      Bring reef-safe sunscreen. The regular kind is banned at several sites and the boat crews do
      check.

      The thing everyone forgets is a spare mask strap. They perish in the sun, they snap on the
      second morning, and the nearest shop is a forty minute drive from Amed.
    TEXT
    translations: {
      "id" => {
        "title" => "Apa yang Perlu Dibawa untuk Trip Freediving di Bali",
        "excerpt" => "Ketebalan wetsuit, tas fin, dan satu barang yang selalu ketinggalan."
      }
    }
  },
  {
    slug: "training-between-trips",
    title: "Keeping Your Depth Between Trips",
    category: "training",
    published_at: nil,
    excerpt: "Dry apnea tables, stretching, and what actually decays when you stop diving.",
    body: <<~TEXT,
      Draft — not yet published. The public API hides this until published_at is set, which makes it
      a useful row for checking that drafts do not leak.
    TEXT
    translations: {}
  }
].each do |attrs|
  article = upsert!(Article, { slug: attrs[:slug] }, attrs)
  attach_cover!(article, attrs[:slug])
end

puts "Seeded: #{User.count} users, #{Instructor.count} instructors, #{Course.count} courses, " \
     "#{Schedule.count} schedules, #{Trip.count} trips, #{Article.count} articles " \
     "(#{ActiveStorage::Attachment.count} images)"
