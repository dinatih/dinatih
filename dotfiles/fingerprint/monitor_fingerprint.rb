#!/usr/bin/env ruby
require 'open3'

def log(msg)
  File.open("/tmp/fingerprint_debug.log", "a") { |f| f.puts "[#{Time.now}] #{msg}" }
  puts "[#{Time.now}] #{msg}"
end

log "Surveillance du capteur Goodix (27c6:609c)..."

Open3.popen2e("stdbuf -oL udevadm monitor --subsystem-match=usb --property") do |stdin, stdout_err, wait_thr|
  stdout_err.each_line do |line|
    if line.include?("ID_MODEL_ID=609c") && line.include?("remove")
      log "!!! DECONNEXION DETECTEE !!!"
      dmesg_tail = `dmesg | tail -n 15`
      log "Logs dmesg :\n#{dmesg_tail}"

      if dmesg_tail.include?("-110")
        log "Cause probable : Timeout UCSI (Power Delivery conflict)"
      elsif dmesg_tail.include?("-5")
        log "Cause probable : E/S Error (Lien physique ou Firmware)"
      end
    end
  end
end
