//
//  ManageAudio.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/02.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import AVFoundation

final class ManageAudio{
    private var audiosWithType: [String : (AudioType, AVAudioPlayer)] = [:]
    var audios: [String : AVAudioPlayer]{
        return audiosWithType.mapValues{ $0.1 }
    }
    private let BGMVolumeKey = "bgmVolume"
    private let SEVolumeKey = "seVolume"
    static let  shared = ManageAudio()
    
    private init(){}
    
    var bgmVolume: Float{
        set(volume){
            let userDefaults: UserDefaults = UserDefaults.standard
            userDefaults.set(volume, forKey: BGMVolumeKey)
            userDefaults.synchronize()
            updateVolume()
        }
        get{
            let userDefaults: UserDefaults = UserDefaults.standard
            guard let volume = userDefaults.object(forKey: BGMVolumeKey) as? Float else{
                return 1.0
            }
            return volume
        }
    }
    
    var seVolume: Float{
        set(volume){
            let userDefaults: UserDefaults = UserDefaults.standard
            userDefaults.set(volume, forKey: SEVolumeKey)
            userDefaults.synchronize()
            updateVolume()
        }
        get{
            let userDefaults: UserDefaults = UserDefaults.standard
            guard let volume = userDefaults.object(forKey: SEVolumeKey) as? Float else{
                return 1.0
            }
            return volume
        }
    }
    
    
    enum AudioType{
        case bgm, se
    }
    
    private func adjust(_ audio: AVAudioPlayer, audioType: AudioType){
        audio.prepareToPlay()
        switch audioType {
        case .bgm:
            audio.volume = bgmVolume
            audio.numberOfLoops = -1
        case .se:
            audio.volume = seVolume
            audio.numberOfLoops = 0
        }
    }
    
    private func updateVolume(){
        audiosWithType.forEach{
            switch $0.value.0{
            case .bgm:
                $0.value.1.volume = bgmVolume
            case .se:
                $0.value.1.volume = seVolume
            }
        }
    }
    
    func getAudioPlayerFromRealm(_ audioNamed: String)-> AVAudioPlayer?{
        guard let data = DataRealm.get(dataNamed: audioNamed) else{
            return nil
        }
        do{
            return try AVAudioPlayer(data: data)
        }catch(let error){
            print("MagageAudio-getAudioPlayer(audioNamed:) AVAudio error")
            dump(error)
        }
        return nil
    }
    
    func getAudioPlayerFromLocal(_ audioNamed: String)-> AVAudioPlayer?{
        let components = audioNamed.components(separatedBy: ".")
        guard let named = components[safe: 0],
            let type = components[safe: 1],
            let path = Bundle.main.path(forResource: named, ofType: type) else{
                print("ManageAudio-getAudioPlayerFromLocal(audioNamed:) file url error. \(audioNamed)")
                return nil
        }
        let url = URL(fileURLWithPath: path)
        
        do{
            return try AVAudioPlayer(contentsOf: url)
        }catch(let error){
            print("MagageAudio-getAudioPlayerFromLocal(audioNamed:) AVAudio error")
            dump(error)
        }
        return nil
    }
    
    func addAudioFromRealm(_ audioNamed: String, audioType: AudioType){
        guard let audioPlayer = getAudioPlayerFromRealm(audioNamed) else{
            return
        }
        audiosWithType[audioNamed] = (audioType, audioPlayer)
        adjust(audioPlayer, audioType: audioType)
    }
    
    func addAudioFromLocal(_ audioNamed: String, audioType: AudioType){
        guard let audioPlayer = getAudioPlayerFromLocal(audioNamed) else{
            return
        }
        audiosWithType[audioNamed] = (audioType, audioPlayer)
        adjust(audioPlayer, audioType: audioType)
    }
    
    func removeAudio(_ audioNamed: String){
        audiosWithType[audioNamed] = nil
    }
    
    func removeAllAudios(){
        audiosWithType.removeAll()
    }
    
    /// 指定した音声ファイルが登録されていたならその音声を１から流す
    func play(_ fileNamed: String){
        guard let audio = audios[fileNamed] else{
            return
        }
        audio.currentTime = 0
        audio.play()
    }
}
