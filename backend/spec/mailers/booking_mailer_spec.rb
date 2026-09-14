require "rails_helper"

RSpec.describe BookingMailer do
  let(:instructor) { create(:instructor, name: "Bagus Wirawan") }
  let(:course) { create(:course, title: "AIDA 2 Freediver", price_cents: 450_000_00) }
  let(:schedule) do
    create(:schedule, course: course, instructor: instructor,
      start_date: Date.new(2026, 10, 5), end_date: Date.new(2026, 10, 7))
  end
  let(:user) { create(:user, name: "Rina Putri", email: "rina@appnea.test") }
  let(:booking) { create(:booking, user: user, schedule: schedule, participants: 2, total_cents: 900_000_00) }

  describe "#received" do
    subject(:mail) { described_class.received(booking) }

    it "addresses the guest" do
      expect(mail.to).to eq([ "rina@appnea.test" ])
      expect(mail.subject).to eq("We received your booking for AIDA 2 Freediver")
    end

    it "renders both parts without raising" do
      expect(mail.html_part.body.to_s).to include("Rina Putri", "AIDA 2 Freediver", "05 Oct", "07 Oct 2026")
      expect(mail.text_part.body.to_s).to include("Rina Putri", "AIDA 2 Freediver")
    end

    it "states that nothing is charged yet" do
      expect(mail.html_part.body.to_s).to include("nothing is charged until then")
    end

    it "formats the total" do
      expect(mail.text_part.body.to_s).to include("Rp 900.000")
    end
  end

  describe "#confirmed" do
    subject(:mail) { described_class.confirmed(booking) }

    it "names the instructor" do
      expect(mail.subject).to eq("Your AIDA 2 Freediver booking is confirmed")
      expect(mail.html_part.body.to_s).to include("Bagus Wirawan")
    end

    it "falls back when no instructor is assigned" do
      schedule.update!(instructor: nil)
      expect(described_class.confirmed(booking.reload).html_part.body.to_s).to include("To be assigned")
    end

    it "renders the text part without raising" do
      expect(mail.text_part.body.to_s).to include("You are confirmed", "AIDA 2 Freediver")
    end
  end
end
