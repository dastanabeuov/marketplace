module AttachableImageRemoval
  extend ActiveSupport::Concern

  included do
    before_action :set_attachable, only: [ :remove_image ]
  end

  def remove_image
    if @attachable.respond_to?(:image) && @attachable.image.attached?
      @attachable.image.purge
      flash[:notice] = t(".destroyed", default: "Image was successfully removed.")
    else
      flash[:alert] = t(".not_destroyed", default: "No image attached.")
    end

    redirect_to polymorphic_path([ :admin, @attachable ])
  end

  private

  # Определим по имени контроллера
  def set_attachable
    model = controller_name.classify.constantize
    @attachable = model.find(params[:id])
  end
end
