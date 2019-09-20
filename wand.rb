#!/usr/bin/env ruby

require 'net/http'
require 'uri'
$stdout.sync = true

valid_wands = [
  '5aa067',
  '5a5c2c'
]
wand_timings = {}
light_state = true
isy_programs = {
  true: '000B',
  false: '0009',
}
WAND_DEBOUNCE_SECS = 4

ARGF.each_line do |line|
  
  if line.match(/ID:(\S+)/)
    wand_id = $1
    wand_timings[wand_id] ||= 0

    if (Time.now - wand_timings[wand_id]).to_i > WAND_DEBOUNCE_SECS
      if valid_wands.include?(wand_id)
        puts "Processing wand: #{wand_id}"

        program_id = isy_programs[light_state.to_s.to_sym]
        uri = URI.parse("http://10.0.1.134/rest/programs/#{program_id}/runThen")
        # puts uri
        request = Net::HTTP::Get.new(uri)
        request.basic_auth("admin", "admin")
        response = Net::HTTP.start(uri.hostname, uri.port, {}) { |http| http.request(request) }
        # puts response.body
        
        light_state = !light_state

      else
        puts "Skipping invalid wand: #{wand_id}"        
      end

      wand_timings[wand_id] = Time.now
    else
      puts "Skipping repeat wand: #{wand_id}"
    end
  end

end
