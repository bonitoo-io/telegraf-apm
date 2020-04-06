class ErrorController < ApplicationController
  @@error_num = 0
  def error
    raise Exception.new("Error in Rails no. #{@@error_num += 1}")
  end
end
