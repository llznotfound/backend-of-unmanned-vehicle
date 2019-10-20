module MAVLink
  module Messages
    #根据接收包的ID进行相应解析
    class Factory

      def self.build(entry)
        case(entry.header.id)
        when 0 then
          result = HeartBeat.new(entry)
          {:custom_mode => result.custom_mode,
           :type => result.type,
           :autopilot => result.autopilot,
           :base_mode => result.base_mode,
           :system_status => result.system_status,
           :mavlink_version => result.mavlink_version}
        when 1 then
          result = SysStatus.new(entry)
          Ocean.first.update(:battery => result.battery_remaining.to_i/255*100.round)
          {:onboard_control_sensors_present => result.onboard_control_sensors_present,
           :onboard_control_sensors_enabled => result.onboard_control_sensors_enabled,
           :onboard_control_sensors_health => result.onboard_control_sensors_health,
           :load => result.load,
           :voltage_battery => result.voltage_battery,
           :current_battery => result.current_battery,
           :drop_rate_comm => result.drop_rate_comm,
           :errors_comm => result.errors_comm,
           :errors_count1 => result.errors_count1,
           :errors_count2 => result.errors_count2,
           :errors_count3 => result.errors_count3,
           :errors_count4 => result.errors_count4,
           :battery_remaining => result.battery_remaining}
        when 11 then
          result = SetMode.new(entry)
          {:custom_mode => result.custom_mode,
           :target_system => result.target_system,
           :base_mode => result.base_mode}
        when 33 then
          result = GlobalPositionInt.new(entry)
          vx = result.vx.to_f
          vy = result.vy.to_f
          vz = result.vz.to_f
          Ocean.first.update(:angle => result.hdg.to_f.round(2),
                             :speed => Math.sqrt(vx**2 + vy**2 + vz**2).round(2),
                             :communicate => -Random.rand(50..120),
                             :time => Random.rand(700),
                             :radius => Random.rand(10.0).round(1))
          PlanStatus.first.update(:lng => result.lon, :lat => result.lat)
          {:time_boot_ms => result.time_boot_ms,
           :lat => result.lat,
           :lon => result.lon,
           :alt => result.alt,
           :relative_alt => result.relative_alt,
           :vx => result.vx,
           :vy => result.vy,
           :vz => result.vz,
           :hdg => result.hdg}
        when 39 then
          result = MissionItem.new(entry)
          {:param1 => result.param1,
           :param2 => result.param2,
           :param3 => result.param3,
           :param4 => result.param4,
           :x => result.x,
           :y => result.y,
           :z => result.z,
           :seq => result.seq,
           :command => result.command,
           :target_system => result.target_system,
           :target_component => result.target_component,
           :frame => result.frame,
           :current => result.current,
           :autocontinue => result.autocontinue,
           :mission_type => result.mission_type}
        when 40 then
          result = MissionRequest.new(entry)
          {:seq => result.seq,
           :target_system => result.target_system,
           :target_component => result.target_component,
           :mission_type => result.mission_type}
        when 44 then
          result = MissionCount.new(entry)
          {:count => result.count,
           :target_system => result.target_system,
           :target_component => result.target_component,
           :mission_type => result.mission_type}
        when 47 then
          result = MissionAck.new(entry)
          {:target_system => result.target_system,
           :target_component => result.target_component,
           :type => result.type,
           :mission_type => result.mission_type}
        when 69 then
          result = MissionManualControl.new(entry)
          {:x => result.x,
           :y => result.y,
           :z => result.z,
           :r => result.r,
           :buttons => result.buttons,
           :target => result.target}
        when 77 then
          result = CommandAck.new(entry)
          {:command => result.command,
           :result => result.result,
           :progress => result.progress,
           :result_param2 => result.result_param2,
           :target_system => result.target_system,
           :target_component => result.target_component}
        when 109 then
          result = RadioStatus.new(entry)
          Ocean.first.update(:communicate => result.rssi.to_f.round(2))
          {:rxerrors => result.rxerrors,
           :fixed => result.fixed,
           :rssi => result.rssi,
           :remrssi => result.remrssi,
           :txbuf => result.txbuf,
           :noise => result.noise,
           :remnoise => result.remnoise}
        else
          nil
        end
      end

    end
  end
end
