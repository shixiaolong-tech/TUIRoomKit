//
//  RoomVideoFloatView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/7/11.
//

import Foundation
import Factory

class RoomVideoFloatView: UIView {
    @Injected(\.floatChatService) private var store: FloatChatStoreProvider
    @Injected(\.conferenceStore) private var conferenceStore: ConferenceStore
    private var isDraging: Bool = false
    private let viewModel: RoomVideoFloatViewModel
    private let space: CGFloat = 10
    private let renderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x5C5C5C)
        return view
    }()
    
    private let shutterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        view.isHidden = true
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let userStatusView: RoomUserStatusView = {
        let view = RoomUserStatusView(frame: .zero)
        return view
    }()
    
    override init(frame: CGRect) {
        viewModel = RoomVideoFloatViewModel()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit:\(self)")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = .clear
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        reportViewShow()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: bounds,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: 10, height: 10))
        avatarImageView.roundedCircle(rect: avatarImageView.bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDraging {
            self.center = adsorption(centerPoint: self.center)
        }
    }
    
    func constructViewHierarchy() {
        addSubview(renderView)
        addSubview(shutterView)
        addSubview(avatarImageView)
        addSubview(userStatusView)
    }
    
    func activateConstraints() {
        renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        shutterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(50)
        }
        userStatusView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.9)
        }
    }
    
    func bindInteraction() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
        addGestureRecognizer(panGesture)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        addGestureRecognizer(tap)
        viewModel.viewResponder = self
        viewModel.showFloatWindowViewVideo()
    }
    
    private func reportViewShow() {
        viewModel.reportFloatWindowShow()
    }
    
    @objc func didTap(sender: UIView) {
        viewModel.showRoomMainView()
    }
    
    @objc func didPan(panGesture: UIPanGestureRecognizer) {
        guard let viewSuperview = superview else { return }
        let moveState = panGesture.state
        let viewCenter = center
        switch moveState {
        case .changed:
            isDraging = true
            let point = panGesture.translation(in: viewSuperview)
            center = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            break
        case .ended:
            let point = panGesture.translation(in: viewSuperview)
            let newPoint = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            UIView.animate(withDuration: 0.2) {
                self.center = self.adsorption(centerPoint: newPoint)
            }
            isDraging = false
            break
        default: break
        }
        panGesture.setTranslation(.zero, in: viewSuperview)
    }
    
    class func show(width: CGFloat = 100, height: CGFloat = 180) {
        DispatchQueue.main.async {
            guard let currentWindow = RoomRouter.getCurrentWindow() else { return }
            let roomFloatView = RoomVideoFloatView()
            currentWindow.addSubview(roomFloatView)
            roomFloatView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-5)
                make.bottom.equalToSuperview().offset(-100)
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }
    }
    
    class func dismiss() {
        DispatchQueue.main.async {
            guard let currentWindow = RoomRouter.getCurrentWindow() else { return }
            let videoFloatViewArray = currentWindow.subviews.filter({ $0 is RoomVideoFloatView })
            for view in videoFloatViewArray {
                view.removeFromSuperview()
            }
        }
    }
    
    private func adsorption(centerPoint: CGPoint) -> CGPoint {
        guard let viewSuperview = superview else { return centerPoint }
        let limitMargin = 5.0
        let frame = self.frame
        let point = CGPoint(x: centerPoint.x - frame.width / 2, y: centerPoint.y - frame.height / 2)
        var newPoint = point
        if centerPoint.x < (viewSuperview.frame.width / 2) {
            newPoint.x = limitMargin
        } else {
            newPoint.x = viewSuperview.frame.width - frame.width - limitMargin
        }
        if point.y <= limitMargin {
            newPoint.y = limitMargin
        } else if (point.y + frame.height) > (viewSuperview.frame.height - limitMargin) {
            newPoint.y = viewSuperview.frame.height - frame.height - limitMargin
        }
        return CGPoint(x: newPoint.x + frame.width / 2, y: newPoint.y + frame.height / 2)
    }
}

extension RoomVideoFloatView: RoomVideoFloatViewResponder {
    func getRenderView() -> UIView {
        return renderView
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
    }
    
    func updateUserStatus(user: UserEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        avatarImageView.sd_setImage(with: URL(string: user.avatarUrl), placeholderImage: placeholder)
        userStatusView.updateUserStatus(userModel: user)
    }
    
    func updateUserVolume(volume: Int) {
        userStatusView.updateUserVolume(volume: volume)
    }
    
    func updateUserAudio(hasAudio: Bool) {
        userStatusView.updateUserAudio(hasAudio)
    }
    
    func showAvatarImageView(isShow: Bool) {
        shutterView.isHidden = !isShow
        avatarImageView.isHidden = !isShow
    }
}
