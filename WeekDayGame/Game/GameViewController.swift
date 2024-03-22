//
//  GameViewController.swift
//  NumberMemoryGame
//
//  Created by 村中令 on 2022/09/14.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class GameViewController: UIViewController {
    private var weekDayGame: WeekDayGame

    @IBOutlet weak var answerTimerProgressView: UIProgressView!
    @IBOutlet weak private var quizTextLabel: UILabel!

    @IBOutlet weak private var weekDayAnswerButton1: UIButton!
    @IBOutlet weak private var weekDayAnswerButton2: UIButton!
    @IBOutlet weak private var weekDayAnswerButton3: UIButton!
    @IBOutlet weak private var weekDayAnswerButton4: UIButton!
    @IBOutlet weak private var weekDayAnswerButton5: UIButton!
    @IBOutlet weak private var weekDayAnswerButton6: UIButton!
    @IBOutlet weak private var weekDayAnswerButton7: UIButton!

    private var AllWeekDayAnswerButtons: [UIButton] {
        return [
        weekDayAnswerButton1,
        weekDayAnswerButton2,
        weekDayAnswerButton3,
        weekDayAnswerButton4,
        weekDayAnswerButton5,
        weekDayAnswerButton6,
        weekDayAnswerButton7
        ]
    }
    private var shuffledAllWeekDayAnswerButtons: [UIButton] = []
    private var dictionaryUIButtonAndWeekDay: [UIButton: DayOfTheWeek] = [:]
    //MARK: - progress
    var progressDuration: Float = 1
    var progressTimer:Timer!
    // MARK: - 音声再生プロパティ
        var audioPlayer: AVAudioPlayer!

    // MARK: - 広告関係のプロパティ
    @IBOutlet weak private var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdBannar()
        initializeProgress()
        startProgressTimer()
        resetAllArrayAndDictionary()
        configureViewQuizTextLabel()
        configureViewButton()
    }
    required init?(coder: NSCoder,level:QuizLevel) {
        weekDayGame = WeekDayGame(level: level)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func answerWeekDay(_ sender: UIButton) {
        let selectedWeekDay = dictionaryUIButtonAndWeekDay[sender]!
        if weekDayGame.answer(input: selectedWeekDay) {
            playSound(name: "correct")
            weekDayGame.reset()
            resetAllArrayAndDictionary()
            configureViewQuizTextLabel()
            configureViewButton()
        } else {
            playSound(name: "miss")
            if weekDayGame.missCount == 5 {
                audioPlayer.stop()
                performSegue(withIdentifier: "result", sender: nil)
            }
        }
    }

    private func resetAllArrayAndDictionary() {
        var randomDayOfTheWeekRawValue = Array(1...7).shuffled()
        var randomDayOfTheWeek : [DayOfTheWeek] = []
        randomDayOfTheWeekRawValue.forEach { num in
            randomDayOfTheWeek.append(DayOfTheWeek(rawValue: num)!)
        }

        shuffledAllWeekDayAnswerButtons = []
        shuffledAllWeekDayAnswerButtons = AllWeekDayAnswerButtons.shuffled()

        dictionaryUIButtonAndWeekDay.removeAll()
        var arrayIndexCount = 0
        let maxIndexArrayButtonAndWeekDay = randomDayOfTheWeek.count - 1
        while arrayIndexCount <= maxIndexArrayButtonAndWeekDay {
            dictionaryUIButtonAndWeekDay.updateValue(
                randomDayOfTheWeek[arrayIndexCount],
                forKey: shuffledAllWeekDayAnswerButtons[arrayIndexCount]
            )
            arrayIndexCount += 1
        }
    }

    private func configureViewQuizTextLabel() {
        quizTextLabel.text = weekDayGame.displayQuizText()
        if DeviceType.isIPhone() {
            quizTextLabel.font = UIFont.boldSystemFont(ofSize: 35.0)
        } else {
            quizTextLabel.font = UIFont.boldSystemFont(ofSize: 70.0)
        }
    }
    private func configureViewButton() {
        AllWeekDayAnswerButtons.forEach { button in
            let buttonTitle = dictionaryUIButtonAndWeekDay[button]?.textJapanese()
            button.setTitle(buttonTitle, for: .normal)
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.init(named: "string")?.cgColor
            button.layer.cornerRadius = 10
            button.setTitleColor(UIColor.init(named: "string"), for: .normal)
            button.setTitleColor(.gray, for: .disabled)
            if DeviceType.isIPhone() {
                button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            } else {
                button.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            }
        }
    }


    // MARK: - 広告関係のメソッド
    private func configureAdBannar() {
        // GADBannerViewのプロパティを設定
        bannerView.adUnitID = "\(GoogleAdID.gameBannerID)"
        bannerView.rootViewController = self
        // 広告読み込み
        bannerView.load(GADRequest())
    }

    //MARK: - progress
    private func initializeProgress() {
        progressDuration = 1.0
        answerTimerProgressView.tintColor = .black
        answerTimerProgressView.setProgress(progressDuration, animated: false)
    }
    private func startProgressTimer() {
        progressTimer
        = Timer
            .scheduledTimer(
                withTimeInterval: 0.01,
                repeats: true) { [weak self] _ in
                    self?.doneProgress()
                }
    }

    private func doneProgress() {
        let milliSecondProgress = 0.0001666
        progressDuration -= Float(milliSecondProgress)
        answerTimerProgressView.setProgress(progressDuration, animated: true)
        if progressDuration <= 0.0 {
            stopProgressTimer()
            guard let audioPlayer = audioPlayer else {
                performSegue(withIdentifier: "result", sender: nil)
                return
            }
            audioPlayer.stop()
            performSegue(withIdentifier: "result", sender: nil)
        }
    }

    private func stopProgressTimer(){
        progressTimer.invalidate()
    }
}
private extension GameViewController {
    @IBSegueAction
    func makeResultVC(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> ResultViewController? {
        return ResultViewController(
            coder: coder,weekDayGame: weekDayGame
        )
    }

    @IBAction
    func backToGameViewController(segue: UIStoryboardSegue) {
    }
}

extension GameViewController: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self

            audioPlayer.prepareToPlay()
            if audioPlayer.isPlaying {
                        audioPlayer.stop()
                        audioPlayer.currentTime = 0
            }
            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }
}
