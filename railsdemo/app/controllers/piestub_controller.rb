class PiestubController < ApplicationController
    def index()
        @ctrl_file = File.expand_path(__FILE__)
    end
end
