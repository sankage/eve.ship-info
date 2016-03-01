get = (url) ->
  # Return a new promise.
  new Promise (resolve, reject) ->
    # Do the usual XHR stuff
    req = new XMLHttpRequest()
    req.open('GET', url)
    req.onload = ->
      # This is called even on 404 etc
      # so check the status
      if req.status is 200
        # Resolve the promise with the response text
        resolve req.response
      else
        # Otherwise reject with the status text
        # which will hopefully be a meaningful error
        reject Error(req.statusText)
    # Handle network errors
    req.onerror = ->
      reject Error("Network Error")
    # Make the request
    req.send()

getJSON = (url) ->
  get(url).then JSON.parse

Function.prototype.method = (name, func) ->
  unless @prototype[name]
    @prototype[name] = func
    @

Function.method 'curry', ->
  slice = Array.prototype.slice
  args = slice.apply arguments
  that = @
  ->
    that.apply null, args.concat(slice.apply(arguments))

find_attribute_in_attributes = (attributes, name) ->
  attribute = attributes.find (a) -> a.attribute.name is name
  attribute.value

percentage = (value) ->
  100 - value * 100

generate_info_window = (ship) ->
  find_attribute = find_attribute_in_attributes.curry(ship.dogma.attributes)
  {
    name: ship.name
    description: ship.description.replace(/\s{2}/, ' ').split("\r\n\r\n")
    attributes:
      structure:
        'Structure Hitpoints (HP)': find_attribute 'hp'
        'Capacity (m3)': ship.capacity
        'Drone Capacity (m3)': find_attribute 'droneCapacity'
        'Drone Bandwidth (Mbit/s)': find_attribute 'droneBandwidth'
        'Mass (kg)': ship.mass
        'Volume (m3)': ship.volume
        'Inertia Modifier': find_attribute 'agility'
        resistance:
          'EM': percentage find_attribute('emDamageResonance')
          'Thermal': percentage find_attribute('thermalDamageResonance')
          'Kinetic': percentage find_attribute('kineticDamageResonance')
          'Explosive': percentage find_attribute('explosiveDamageResonance')
      armor:
        'Armor Hitpoints (HP)': find_attribute 'armorHP'
        resistance:
          'EM': percentage find_attribute('armorEmDamageResonance')
          'Thermal': percentage find_attribute('armorThermalDamageResonance')
          'Kinetic': percentage find_attribute('armorKineticDamageResonance')
          'Explosive': percentage find_attribute('armorExplosiveDamageResonance')
      shield:
        'Shield Capacity (HP)': find_attribute 'shieldCapacity'
        'Shield recharge time (ms)': find_attribute 'shieldRechargeRate'
        resistance:
          'EM': percentage find_attribute('shieldEmDamageResonance')
          'Thermal': percentage find_attribute('shieldThermalDamageResonance')
          'Kinetic': percentage find_attribute('shieldKineticDamageResonance')
          'Explosive': percentage find_attribute('shieldExplosiveDamageResonance')
      capacitor:
        'Capacitor Capacity (GJ)': find_attribute 'capacitorCapacity'
        'Capacitor Recharge time (ms)': find_attribute 'rechargeRate'
      targeting:
        'Maximum Targeting Range (m)': find_attribute 'maxTargetRange'
        'Maximum Locked Targets': find_attribute 'maxLockedTargets'
        'Signature Radius (m)': find_attribute 'signatureRadius'
        'Scan Resolution (mm)': find_attribute 'scanResolution'
        sensor_strength:
          'RADAR Sensor Strength': find_attribute 'scanRadarStrength'
          'Ladar Sensor Strength': find_attribute 'scanLadarStrength'
          'Magnetometric Sensor Strength': find_attribute 'scanMagnetometricStrength'
          'Gravimetric Sensor Strength': find_attribute 'scanGravimetricStrength'
      propulsion:
        'Maximum Velocity (m/s)': find_attribute 'maxVelocity'
        'Ship Warp Speed (AU/s)': find_attribute 'warpSpeedMultiplier'
    fitting:
      'CPU Output (tf)': find_attribute 'cpuOutput'
      'Powergrid Output (MW)': find_attribute 'powerOutput'
      'Calibration': find_attribute 'upgradeCapacity'
      'Turret Hardpoints': find_attribute 'turretSlotsLeft'
      'Launcher Hardpoints': find_attribute 'launcherSlotsLeft'
      'High Power Slots': find_attribute 'hiSlots'
      'Medium Power Slots': find_attribute 'medSlots'
      'Low Power Slots': find_attribute 'lowSlots'
      'Medium Rig Slots': find_attribute 'rigSlots'
  }

get_ship = (ship_id) ->
  getJSON('https://public-crest.eveonline.com/types/' + ship_id + '/')
    .then (ship) ->
      info_window = generate_info_window(ship)
      console.log info_window
      ship

get_ship(22474)


