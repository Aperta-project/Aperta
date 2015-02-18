require 'test_helper'

module BillingCard
  class BillingDetailsControllerTest < ActionController::TestCase
    setup do
      @billing_detail = billing_details(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:billing_details)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create billing_detail" do
      assert_difference('BillingDetail.count') do
        post :create, billing_detail: {  }
      end

      assert_redirected_to billing_detail_path(assigns(:billing_detail))
    end

    test "should show billing_detail" do
      get :show, id: @billing_detail
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @billing_detail
      assert_response :success
    end

    test "should update billing_detail" do
      patch :update, id: @billing_detail, billing_detail: {  }
      assert_redirected_to billing_detail_path(assigns(:billing_detail))
    end

    test "should destroy billing_detail" do
      assert_difference('BillingDetail.count', -1) do
        delete :destroy, id: @billing_detail
      end

      assert_redirected_to billing_details_path
    end
  end
end
