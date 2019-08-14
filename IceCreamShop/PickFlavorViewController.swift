/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyXMLParser

public class PickFlavorViewController: UIViewController {

  // MARK: - Instance Properties
  public var flavors: [Flavor] = []
  fileprivate let flavorFactory = FlavorFactory()

  // MARK: - Outlets
  @IBOutlet var contentView: UIView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var iceCreamView: IceCreamView!
  @IBOutlet var label: UILabel!

  // MARK: - View Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()

    loadFlavors()
  }

  var timerCounter = 0
  fileprivate func loadFlavors() {
    // TO-DO: Implement this
    showLoadingHUD()
    
    let timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { (timer) in
      self.timerCounter += 1
      print("timer went off \(self.timerCounter) times")
      // do stuff 42 seconds later
    }
    RunLoop.current.add(timer, forMode: .commonModes)
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5.0, execute: {
      print("after delay")
      DispatchQueue.main.sync {
        let lbl = UILabel()
        lbl.backgroundColor = .black
        lbl.textColor = .white
        lbl.text = "Hello"
        lbl.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.contentView.addSubview(lbl)
      }
      })
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
    // 1
    Alamofire.request(
      "https://www.raywenderlich.com/downloads/Flavors.plist",
      method: .get,
      encoding: PropertyListEncoding(format: .xml, options: 0)).responsePropertyList {
        [weak self] response in
        
        // 2
        guard let strongSelf = self else { return }
        
        strongSelf.hideLoadingHUD()
        // 3
        guard response.result.isSuccess,
          let dictionaryArray = response.result.value as? [[String: String]] else {
            return
        }
        
        // 4
        strongSelf.flavors = strongSelf.flavorFactory.flavors(from: dictionaryArray)
        
        // 5
        strongSelf.collectionView.reloadData()
        strongSelf.selectFirstFlavor()
    }
    })//end asyncAfter
    
    //extra
    Alamofire.request("https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&stationString=KDEN%20KSEA%20PHNL&hoursBeforeNow=2").response { response in
        if let data = response.data {
          let xml = XML.parse(data)
         // let datastring = String.init(data: data, encoding: String.Encoding.utf8)
        
          print(xml["response","data","METAR",0,"station_id"].text!)
          for i in 0...3 {
            print(xml.response.data.METAR[i].station_id.text!)
            if let myInt = Int(xml.response.time_taken_ms.text!) {
            print(myInt)
            }
            if let myTxt = xml.response.data.METAR[i].sky_condition[0].attributes["sky_cover"]{
              print(myTxt)
            }              //print(xml["response","data","METAR",i,"station_id"].text!)
          }
          //print(datastring)// the top title of iTunes app raning.
      }
     // debugPrint(response)
        }
    
    
  }

  private func showLoadingHUD() {
    let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
    hud.label.text = "Loading..."
  }
  
  private func hideLoadingHUD() {
    MBProgressHUD.hide(for: contentView, animated: true)
  }

  fileprivate func selectFirstFlavor() {
    guard let flavor = flavors.first else {
      return
    }
    update(with: flavor)
  }
}

// MARK: - FlavorAdapter
extension PickFlavorViewController: FlavorAdapter {

  public func update(with flavor: Flavor) {
    iceCreamView.update(with: flavor)
    label.text = flavor.name
  }
}

// MARK: - UICollectionViewDataSource
extension PickFlavorViewController: UICollectionViewDataSource {

  private struct CellIdentifiers {
    static let scoop = "ScoopCell"
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return flavors.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.scoop, for: indexPath) as! ScoopCell
    let flavor = flavors[indexPath.row]
    cell.update(with: flavor)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension PickFlavorViewController: UICollectionViewDelegate {

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let flavor = flavors[indexPath.row]
    update(with: flavor)
  }
}
/* Note: multiple metars normally - cause Multipe elements error.
 <response version="1.2" xsi:noNamespaceSchemaLocation="http://aviationweather.gov/adds/schema/metar1_2.xsd">
      <request_index>49453490</request_index>
      <data_source name="metars"/>
      <request type="retrieve"/>
      <errors/>
      <warnings/>
      <time_taken_ms>9</time_taken_ms>
      <data num_results="6">
            <METAR>
                <raw_text>KDEN 132153Z 06010G19KT 10SM FEW100 FEW220 31/07 A3019 RMK AO2 SLP133 T03060072</raw_text>
                <station_id>KDEN</station_id>
                <observation_time>2019-08-13T21:53:00Z</observation_time>
                <latitude>39.85</latitude>
                <longitude>-104.65</longitude>
                <temp_c>30.6</temp_c>
                <dewpoint_c>7.2</dewpoint_c>
                <wind_dir_degrees>60</wind_dir_degrees>
                <wind_speed_kt>10</wind_speed_kt>
                <wind_gust_kt>19</wind_gust_kt>
                <visibility_statute_mi>10.0</visibility_statute_mi>
                <altim_in_hg>30.188976</altim_in_hg>
                <sea_level_pressure_mb>1013.3</sea_level_pressure_mb>
                <quality_control_flags>
                        <auto_station>TRUE</auto_station>
                </quality_control_flags>
                <sky_condition sky_cover="FEW" cloud_base_ft_agl="10000"/>
                <sky_condition sky_cover="FEW" cloud_base_ft_agl="22000"/>
                <flight_category>VFR</flight_category>
                <metar_type>SPECI</metar_type>
                <elevation_m>1640.0</elevation_m>
           </METAR>
      </data>
 </response>
 */
