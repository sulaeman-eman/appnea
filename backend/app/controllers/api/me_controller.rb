module Api
  class MeController < BaseController
    before_action :authenticate_user!

    def show
      render json: { user: UserBlueprint.render_as_hash(current_user) }
    end
  end
end
