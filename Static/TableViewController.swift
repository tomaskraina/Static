import UIKit

/// Table view controller with a `DataSource` setup to use its `tableView`.
open class TableViewController: UIViewController {

    private lazy var __once: () = { [weak self] in
            self?.tableView.reloadData()
    }()

    // MARK: - Properties

    /// Returns the table view managed by the controller object.
    open let tableView: UITableView

    /// A Boolean value indicating if the controller clears the selection when the table appears.
    ///
    /// The default value of this property is true. When true, the table view controller clears the table’s current selection when it receives a viewWillAppear: message. Setting this property to false preserves the selection.
    open var clearsSelectionOnViewWillAppear: Bool = true

    /// Table view data source.
    open var dataSource = DataSource() {
        willSet {
            dataSource.tableView = nil
        }

        didSet {
            dataSource.tableView = tableView
        }
    }


    // MARK: - Initialization

    public init(style: UITableViewStyle) {
        tableView = UITableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        dataSource.tableView = tableView
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource.tableView = tableView
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public convenience init() {
        self.init(style: .plain)
    }


    // MARK: - UIViewController

    open override func loadView() {
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = tableView
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performInitialLoad()
        clearSelectionsIfNecessary(animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }


    // MARK: - Private

    fileprivate var initialLoadOnceToken = Int()
    fileprivate func performInitialLoad() {
        _ = self.__once
    }

    fileprivate func clearSelectionsIfNecessary(_ animated: Bool) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows, clearsSelectionOnViewWillAppear else { return }
        guard let coordinator = transitionCoordinator else {
            deselectRowsAtIndexPaths(selectedIndexPaths, animated: animated)
            return
        }

        let animation: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.deselectRowsAtIndexPaths(selectedIndexPaths, animated: animated)
        }

        let completion: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] context in
            if context.isCancelled {
                self?.selectRowsAtIndexPaths(selectedIndexPaths, animated: animated)
            }
        }

        coordinator.animate(alongsideTransition: animation, completion: completion)
    }

    fileprivate func selectRowsAtIndexPaths(_ indexPaths: [IndexPath], animated: Bool) {
        indexPaths.forEach { tableView.selectRow(at: $0, animated: animated, scrollPosition: .none) }
    }

    fileprivate func deselectRowsAtIndexPaths(_ indexPaths: [IndexPath], animated: Bool) {
        indexPaths.forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
}
