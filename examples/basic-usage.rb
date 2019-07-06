# -*- ruby -*-
# frozen_string_literal: true

require 'observability'


class Server
	extend Observability


	observer 'udp://10.2.0.250:11311'

	observe_around :handle_request
	observe_around :handle_


end # class Server

