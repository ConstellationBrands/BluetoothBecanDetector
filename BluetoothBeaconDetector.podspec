Pod::Spec.new do |s|
          #1.
          s.name               = "BluetoothBeaconDetector"
          #2.
          s.version            = "1.0.0"
          #3.  
          s.summary         = "Finding Beacons and sending Latitude and Longitude data"
          #4.
          s.homepage        = "https://github.com/ConstellationBrands/BluetoothBecanDetector"
          #5.
          s.license              = "Constellation Brands"
          #6.
          s.author               = "Saranya Jayaseelan"
          #7.
          s.platform            = :ios, "10.0"
          #8.
          s.source              = { :git => "https://github.com/ConstellationBrands/BluetoothBecanDetector.git", :tag => "1.0.0" }
          #9.
          s.source_files     = "BluetoothBeaconDetector", "BluetoothBeaconDetector/**/*.{h,m,swift}"
    end
