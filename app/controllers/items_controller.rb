class ItemsController < ApplicationController

  require 'payjp'
  # before_action :move_to_index

  def index
  end

  def new
    @item = Item.new
    @item.images.build
    @item.build_brand
    @item.build_shipment

    @category_parent_array = ["選択してください"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      # flash.now[:alert] = "必須項目を入力して下さい"
      redirect_to new_item_path, flash: { alert: "必須項目を入力して下さい"}
      # render action: :new
    end
  end

  def show
  end

  def edit
    @item = Item.find(params[:id])
    
    grandchild_category = @item.category
    child_category = grandchild_category.parent


    @category_parent_array = ["選択してください"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end

    @category_children_array = ["選択してください"]
    Category.where(ancestry: child_category.ancestry).each do |children|
      @category_children_array << children.name
    end

    @category_grandchildren_array = ["選択してください"]
    Category.where(ancestry: grandchild_category.ancestry).each do |grandchildren|
      @category_grandchildren_array << grandchildren.name
    end
    
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_update_params)
      redirect_to root_path
    else
      redirect_to edit_item_path(params[:id]), flash: { alert: "必須項目を入力して下さい"}
    end
  end


  def purchase
    Payjp.api_key = "sk_test_5b7e13cb76bbe5226e8504b2"
    Payjp::Charge.create(
      amount: 809, # 決済する値段
      card: params['payjp-token'], # フォームを送信すると作成・送信されてくるトークン
      currency: 'jpy'
    )
  end
  
  def move_to_index
    redirect_to root_path unless user_signed_in?
  end

  def get_category_children
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  private
  def item_params
    params.require(:item)
          .permit(:name,
                  :info,
                  :status,
                  :category_id,
                  :switch,
                  :value,
                  :sold,
                  images_attributes:[
                    :image
                  ],
                  brand_attributes:[
                    :name
                  ],
                  shipment_attributes:[
                    :delivery_burden,
                    :prefecture_id,
                    :days
                  ])
          .merge(user_id: current_user.id)

  end

  def item_update_params
    params.require(:item)
          .permit(:name,
                  :info,
                  :status,
                  :category_id,
                  :switch,
                  :value,
                  :sold,
                  images_attributes: [
                    :image, 
                    :_destroy, 
                    :id
                  ],
                  brand_attributes:[
                    :name
                  ],
                  shipment_attributes:[
                    :delivery_burden,
                    :prefecture_id,
                    :days
                  ])
          .merge(user_id: current_user.id)
  end
end
