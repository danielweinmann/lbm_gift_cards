class GiftCardsController < StateController
  
  before_action :set_gift_card, except: %i[index new create]

  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  respond_to :html, except: %i[redeem]
  respond_to :json, only: %i[redeem]

  def index
    @gift_cards = policy_scope(GiftCard)
    respond_with @gift_cards
  end

  def show
    authorize @gift_card
    respond_with @gift_card
  end

  def new
    @gift_card = GiftCard.new user: current_user
    authorize @gift_card
    respond_with @gift_card
  end

  def create
    @gift_card = GiftCard.new(gift_card_params)
    @gift_card.user = current_user
    authorize @gift_card
    @gift_card.save
    respond_with @gift_card, location: -> { root_path }
  end

  def edit
    authorize @gift_card
    respond_with @gift_card
  end

  def update
    authorize @gift_card
    @gift_card.update(gift_card_params)
    respond_with @gift_card
  end

  def destroy
    authorize @gift_card
    @gift_card.destroy
    respond_with @gift_card
  end

  def redeem
    authorize @gift_card
    return render json: { error: 'no_value', message: t('.no_value') }, status: 422 unless params[:value].present?
    return render json: { error: 'wrong_value', message: t('.wrong_value') }, status: 422 unless params[:value].to_i == @gift_card.value.to_i
    return render json: { error: 'cant_redeem', message: t('.cant_redeem') }, status: 422 unless @gift_card.can_redeem?
    transition_state(:redeem)
  end

  def invalidate
    transition_state(:invalidate)
  end

  private

  def gift_card_params
    params.require(:gift_card).permit(*policy(@gift_card || GiftCard.new).permitted_attributes)
  end

  def set_gift_card
    @gift_card = GiftCard.find_by_code!(params[:id])
  end

  def transition_state(transition)
    super(@gift_card, transition, root_path)
  end

end
