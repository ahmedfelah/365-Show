//
//  FilterViewController.swif
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/3/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate : AnyObject {
    func filterViewController(_ filterViewController: FilterViewController, didSelectFilter filter: ShoofAPI.Filter)
}

extension ShoofAPI.Genre : MenuSelection {
    var localizedString: String { name }
}

extension String : MenuSelection {
    var localizedString: String { self }
}

extension UIButton {
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}

class FilterMenuButton : UIButton {
    let titleView: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.6)
        label.font = Fonts.almarai(14)
        return label
    }()
    
    let arrowImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "dropdownarrow"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var contentView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, UIView(), arrowImageView])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.backgroundColor = .red
        return stackView
    }()
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        titleView.text = title
    }
    
    override var isHighlighted: Bool {
        get {
            super.isHighlighted
        }
        
        set {
            super.isHighlighted = newValue
            
            UIView.animate(withDuration: 0.1, animations: updateBackgroundColor)
        }
    }
    
    override var isSelected: Bool {
        get {
            super.isSelected
        } set {
            super.isSelected = newValue
            
            UIView.animate(withDuration: 0.1, animations: updateBackgroundColor)
        }
    }
    
    private func updateBackgroundColor() {
        if isHighlighted {
            backgroundColor = Theme.current.secondaryColor.withAlphaComponent(0.8)
        } else if isSelected {
            backgroundColor = Theme.current.secondaryLightColor
        } else {
            backgroundColor = Theme.current.secondaryColor
        }
    }
    
    private func setup() {
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            arrowImageView.heightAnchor.constraint(equalToConstant: 14),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14)
        ])
        
        backgroundColor = Theme.current.secondaryColor
        layer.borderColor = Theme.current.secondaryLightColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

class FilterItemCell : UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.6)
        label.font = Fonts.almarai(14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        } set {
            super.isSelected = newValue
            
            if newValue {
                contentView.backgroundColor = Theme.current.secondaryLightColor
                titleLabel.font = Fonts.almaraiBold(14)
                titleLabel.textColor = .white.withAlphaComponent(0.8)
            } else {
                contentView.backgroundColor = Theme.current.secondaryColor
                titleLabel.textColor = .white.withAlphaComponent(0.6)
                titleLabel.font = Fonts.almarai(14)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.backgroundColor = Theme.current.secondaryColor
        
        contentView.layer.borderColor = Theme.current.secondaryLightColor.cgColor
        contentView.layer.borderWidth = 1
    }
}


enum SortType : Int, CaseIterable, Codable {
    case yearAscending = 1
    case yearDescending = 2
    case rateAscending = 3
    case rateDescending = 4
    case viewsAscending = 5
    case viewsDescending = 6
    case uploadDateAscending = 7
    case uploadDateDescending = 8
    
    
    var localizedDescription : String {
        NSLocalizedString(String(describing: self), comment: "")
    }
}

extension SortType {
    var indexPath: IndexPath {
        IndexPath(row: rawValue - 1, section: 0)
    }
}

extension ShoofAPI.Filter.MediaType {
    var indexPath: IndexPath {
        IndexPath(row: rawValue, section: 0)
    }
    
    var localizedDescription: String {
        NSLocalizedString(String(describing: self), comment: "")
    }
}

class FilterViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, SelectionMenuDelegate {
    
    func selectionMenu<Selection>(_ selectionMenu: SelectionMenu<Selection>, didSelect item: Selection) where Selection : MenuSelection {
        if let selectedGenre = selectionMenu.currentSelection as? ShoofAPI.Genre {
            currentFilter.genreID = selectedGenre.id
            genreButton.isSelected = true
            genreButton.setTitle(NSLocalizedString("\(selectedGenre.name)", comment: ""), for: .normal)
        } else if let selectedYear  = selectionMenu.currentSelection as? String {
            currentFilter.year = selectedYear
            yearButton.isSelected = true
            yearButton.setTitle(selectedYear, for: .normal)
        }
        
        selectionMenu.dismiss(animated: true)
    }
    
//    var selectedYear: String?
//    var selectedGenre: ShoofAPI.Genre?
//    var selectedSortType: SortType?
//    var selectedShowType: ShowType?
    
    var currentFilter: ShoofAPI.Filter
    
    var sortTypeAscending: [SortType] = [.yearDescending, .rateDescending, .viewsDescending, .uploadDateDescending]
    
    init(filter: ShoofAPI.Filter) {
        self.currentFilter = filter
        
        switch currentFilter.sortType {
        case .yearAscending:
            currentFilter.sortType = .yearDescending
        case .rateAscending:
            currentFilter.sortType = .rateDescending
        case .viewsAscending:
            currentFilter.sortType = .viewsDescending
        case .uploadDateAscending:
            currentFilter.sortType = .uploadDateDescending
        default:
            print("")
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum ShowType: Int, CaseIterable {
        case movies, series, all
        
        var localizedDescription: String {
            NSLocalizedString(String(describing: self), comment: "")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == sortingCollectionView ? sortTypeAscending.count : ShowType.allCases.count
//        return SortType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sortingCollectionView {
            self.currentFilter.sortType = sortTypeAscending[indexPath.row]
//            self.selectedSortType = SortType.allCases[indexPath.row]
        } else {
            self.currentFilter.mediaType = .allCases[indexPath.row]
//            let showType = ShowType.allCases[indexPath.row]
//            self.currentFilter.isMovie = showType == .movies ? true : showType == .series ? false : nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sortingCollectionView {
            let height : CGFloat = collectionView.bounds.height
            let padding : CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 120 : 60
            let itemSize: CGSize = sortTypeAscending[indexPath.row].localizedDescription.localizedUppercase.size(withAttributes: [.font : Fonts.almarai(13)])
            return CGSize(width: itemSize.width + padding, height: height)
        } else {
            let width = (collectionView.bounds.width - CGFloat((ShowType.allCases.count - 1) * 10)) / CGFloat(ShowType.allCases.count)
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterItemCell
        
        if collectionView == sortingCollectionView {
            let sortType = sortTypeAscending[indexPath.row]
            cell.titleLabel.text = sortType.localizedDescription.localizedUppercase
        } else {
            let showType = ShowType.allCases[indexPath.row]
            cell.titleLabel.text = showType.localizedDescription.localizedUppercase
        }
        
        return cell
    }
    
    lazy var sortingCollectionView: UICollectionView = {
        let layout = ArabicCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(FilterItemCell.self, forCellWithReuseIdentifier: "FilterCell")
        return collectionView
    }()
    
    lazy var typeCollectionView : UICollectionView = {
       let layout = ArabicCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
//        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(FilterItemCell.self, forCellWithReuseIdentifier: "FilterCell")
        return collectionView
    }()
    
    weak var delegate: FilterViewControllerDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filter", comment: "")
        label.textColor = Theme.current.textColor
        label.font = Fonts.almarai(14)
        return label
    }()
    
    lazy var resetButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("reset", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        button.titleLabel?.font = Fonts.almaraiBold(14)
        button.setTitleColor(Theme.current.tintColor, for: .normal)
//        button.tintColor = Colors.button
        return button
    }()
    
    lazy var topStackView : UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [titleLabel, spacer, resetButton])
        stackView.axis = .horizontal
        return stackView
    }()
    
    var allYears: [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let years = (1900...currentYear).map(String.init)
        return years.reversed()
    }
    
    lazy var genreButton : FilterMenuButton = {
        let genreButton = FilterMenuButton()
        let genreName = ShoofAPI.Genre.allGenres.first(where: { $0.id == currentFilter.genreID })?.name
        genreButton.setTitle(NSLocalizedString("\(genreName ?? "genreButtonTitle")", comment: ""), for: .normal)
//        genreButton.setBackgroundColor(Colors.darkGray, for: .normal)
//        genreButton.setBackgroundImage(UIImage(named: "genremenu"), for: .normal)
//        genreButton.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
//        genreButton.titleLabel?.font = Fonts.almarai(14)
        genreButton.tag = 0
//        genreButton.layer.borderColor = Colors.lightGray.cgColor
//        genreButton.layer.borderWidth = 1
        genreButton.addTarget(self, action: #selector(handleGenreButtonTap), for: .touchUpInside)
        
        return genreButton
    }()
    
    lazy var yearButton : FilterMenuButton = {
        let yearButton = FilterMenuButton()
        yearButton.setTitle(NSLocalizedString("\(currentFilter.year ?? "yearButtonTitle")", comment: ""), for: .normal)
//        yearButton.setBackgroundColor(Colors.darkGray, for: .normal)
//        yearButton.setBackgroundImage(UIImage(named: "yearmenu"), for: .normal)
//        yearButton.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
//        yearButton.titleLabel?.font = Fonts.almarai(14)
        yearButton.tag = 1
//        yearButton.layer.borderColor = Colors.lightGray.cgColor
//        yearButton.layer.borderWidth = 1
        yearButton.addTarget(self, action: #selector(handleGenreButtonTap), for: .touchUpInside)
        
        return yearButton
    }()
    
    lazy var genreYearStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [genreButton, yearButton])
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    lazy var sortingStackView : UIStackView = {
        let label = UILabel()
        label.text = NSLocalizedString("sortingBy", comment: "")
        label.font = Fonts.almarai(15)
        label.textColor = Theme.current.textColor
        
        let stackView = UIStackView(arrangedSubviews: [label, sortingCollectionView, UIView()])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
//        stackView.alignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 8).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        sortingCollectionView.translatesAutoresizingMaskIntoConstraints = false
        sortingCollectionView.heightAnchor.constraint(equalToConstant: 46).isActive = true
        sortingCollectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 8.5).isActive = true
        sortingCollectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -8.5).isActive = true
        sortingCollectionView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -11).isActive = true
        
        stackView.backgroundColor = .white.withAlphaComponent(0.03)
        stackView.layer.borderWidth = 0.1
        stackView.layer.cornerRadius = 6
        stackView.layer.borderColor = Theme.current.textColor.cgColor
        
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    lazy var typeStackView : UIStackView = {
        let label = UILabel()
        label.text = NSLocalizedString("type", comment: "")
        label.font = Fonts.almarai(15)
        label.textColor = Theme.current.textColor
        
        let stackView = UIStackView(arrangedSubviews: [label, typeCollectionView, UIView()])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
//        stackView.alignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 8).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        typeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        typeCollectionView.heightAnchor.constraint(equalToConstant: 46).isActive = true
        typeCollectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 8.5).isActive = true
        typeCollectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -8.5).isActive = true
        typeCollectionView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -11).isActive = true
        stackView.backgroundColor = .white.withAlphaComponent(0.03)
        stackView.layer.borderWidth = 0.1
        stackView.layer.borderColor = Theme.current.textColor.cgColor
        stackView.layer.cornerRadius = 6
        
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    lazy var showResultsButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("showResults", comment: ""), for: .normal)
        button.titleLabel?.font = Fonts.almaraiBold(15)
        button.setBackgroundColor(Theme.current.tintColor, for: .normal)
        button.addTarget(self, action: #selector(showResults), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [topStackView, genreYearStackView, typeStackView, sortingStackView, spacer, showResultsButton])
        stackView.axis = .vertical
        stackView.spacing = 18
        
        genreYearStackView.translatesAutoresizingMaskIntoConstraints = false
        genreYearStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        showResultsButton.translatesAutoresizingMaskIntoConstraints = false
        showResultsButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.current.backgroundColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    let defaultHeight: CGFloat = 500
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    @objc func reset(sender: UIButton) {
        typeCollectionView.indexPathsForSelectedItems?.forEach { indexPath in
            typeCollectionView.deselectItem(at: indexPath, animated: true)
        }
        
        sortingCollectionView.indexPathsForSelectedItems?.forEach { indexPath in
            sortingCollectionView.deselectItem(at: indexPath, animated: true)
        }
        
        currentFilter = .none
        
        genreButton.isSelected = false
        yearButton.isSelected = false
        
        genreButton.setTitle(NSLocalizedString("genreButtonTitle", comment: ""), for: .normal)
        yearButton.setTitle(NSLocalizedString("yearButtonTitle", comment: ""), for: .normal)
    }
    
    @objc func handleGenreButtonTap(sender: FilterMenuButton) {
        if sender.tag == 0 {
            let vc = SelectionMenu<ShoofAPI.Genre>()
            vc.values = ShoofAPI.Genre.allGenres
            vc.currentSelection = ShoofAPI.Genre.allGenres.first(where: { $0.id == currentFilter.genreID })
            vc.delegate = self
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.sourceView = sender.arrowImageView
            vc.popoverPresentationController?.sourceRect = sender.arrowImageView.bounds
            vc.popoverPresentationController?.permittedArrowDirections = .up
            present(vc, animated: true)
        } else if sender.tag == 1 {
            let vc = SelectionMenu<String>()
            vc.values = allYears
            vc.currentSelection = currentFilter.year
            vc.delegate = self
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.sourceView = sender.arrowImageView
            vc.popoverPresentationController?.sourceRect = sender.arrowImageView.bounds
            vc.popoverPresentationController?.permittedArrowDirections = .up
            present(vc, animated: true)
        }
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func showResults(sender: UIButton) {
        delegate?.filterViewController(self, didSelectFilter: currentFilter)
        animateDismissView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        typeCollectionView.selectItem(at: currentFilter.mediaType.indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        if let selectedSortType = currentFilter.sortType {
            let indexPath = IndexPath(item: sortTypeAscending.firstIndex(of: selectedSortType) ?? 0, section: 0)
            sortingCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // content stackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
//            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        } else {
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        if #available(iOS 11, *), let constant = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, constant > 0 {
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -constant).isActive = true
        } else {
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
        }
        
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}
