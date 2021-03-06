class ProductsController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show, :search]

  def index
    only_show_discount = params[:discount] == "true"
    if only_show_discount
      @products = Product.where("price < ?", 10)
    elsif params[:category_name] != nil
      selected_category = Category.find_by(name: params[:category_name])
      @products = selected_category.products
    else
      sort_attribute = params[:sort] || "name"
      sort_order = params[:sort_order] || "asc"
      @products = Product.order(sort_attribute => sort_order)
    end
    render 'index.html.erb'
  end

  def new
    render 'new.html.erb'
  end

  def create
    @product = Product.new(
      name: params[:name],
      description: params[:description],
      price: params[:price],
      supplier_id: 1
    )
    if @product.save
      image = Image.new(
        url: params[:image],
        product_id: @product.id
      )
      image.save
      flash[:success] = "Product Created"
      redirect_to "/products/#{@product.id}"
    else
      render 'new.html.erb'
    end
  end

  def show
    if params[:id] == "random"
      products = Product.all
      @product = products.sample
    else
      @product = Product.find_by(id: params[:id])
    end
    render 'show.html.erb'
  end

  def edit
    @product = Product.find_by(id: params[:id])
    render 'edit.html.erb'
  end

  def update
    @product = Product.find_by(id: params[:id])
    @product.name = params[:name]
    @product.description = params[:description]
    @product.price = params[:price]
    @product.save
    flash[:success] = "Product Updated"
    redirect_to "/products/#{@product.id}"
  end

  def destroy
    @product = Product.find_by(id: params[:id])
    @product.destroy
    flash[:warning] = "Product Destroyed"
    redirect_to "/products"
  end

  def search
    search_term = params[:search]
    @products = Product.where("name LIKE ?", '%' + search_term + '%')
    render 'index.html.erb'
  end
end

