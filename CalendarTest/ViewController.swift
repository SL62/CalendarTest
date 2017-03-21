//
//  ViewController.swift
//  CalendarTest
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
	
	var selectedDate: Date?
	
	// Set start and end date +/- 1 year from now
	let startDate = Date().addingTimeInterval(-31536000)
	let endDate = Date().addingTimeInterval(31536000)
	
	var monthFormatter = DateFormatter()
	
	var showCalendar = false
	
	@IBOutlet weak var leftBarButton: UIBarButtonItem!
	@IBOutlet weak var rightBarButton: UIBarButtonItem!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var calendarView: JTAppleCalendarView!
	
	@IBOutlet weak var daysOfWeekHeight: NSLayoutConstraint!
	@IBOutlet weak var calendarHeight: NSLayoutConstraint!
	
	//******************************************************************************************************************
	// OVERRIDE VIEW
	//******************************************************************************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		monthFormatter.dateFormat = "MMMM YYYY"
		tableView.reloadData()
		
		// Set up calendar view
		calendarView.delegate = self
		calendarView.dataSource = self
		calendarView.registerCellViewXib(file: "CalendarCellView")
		calendarView.cellInset = CGPoint(x: 0, y: 0)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Set current day as selected date
		if selectedDate == nil {
			selectedDate = self.roundToNearest1d(from: Date())
		}
		
		guard let selectedDate = selectedDate else { return }
		print("Selected date : \(selectedDate)")
		
		self.view.layoutIfNeeded()
		
		// Set up view depending on whether show calendar bool
		if !showCalendar {
			
			calendarHeight.constant = 0.0
			daysOfWeekHeight.constant = 0.0
			leftBarButton.title = ""
			rightBarButton.title = "Show"
			
		} else {
			
			calendarHeight.constant = 240.0
			daysOfWeekHeight.constant = 30.0
			leftBarButton.title = self.monthFormatter.string(from: selectedDate)
			rightBarButton.title = "Hide"
		}
		
		self.calendarView.reloadData(withAnchor: selectedDate, animation: false, completionHandler: nil)
		self.calendarView.selectDates([selectedDate])
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	//******************************************************************************************************************
	// IBACTIONS
	//******************************************************************************************************************
	
	@IBAction func changeView(_ sender: Any) {
		
		guard let selectedDate = selectedDate else { return }
		print("Selected date : \(selectedDate)")
		
		// Toggle show calendar
		showCalendar = !showCalendar
		
		self.view.layoutIfNeeded()
		
		// Set up view depending on whether schedule or monthly view has been selected
		if !showCalendar {
			
			UIView.animate(withDuration: 0.3) {
				self.calendarHeight.constant = 0.0
				self.daysOfWeekHeight.constant = 0.0
				self.leftBarButton.title = ""
				self.rightBarButton.title = "Show"
				self.view.layoutIfNeeded()
			}
			
		} else {
			
			UIView.animate(withDuration: 0.3) {
				self.calendarHeight.constant = 240.0
				self.daysOfWeekHeight.constant = 30.0
				self.leftBarButton.title = self.monthFormatter.string(from: selectedDate)
				self.rightBarButton.title = "Hide"
				self.view.layoutIfNeeded()
			}
		}
		
		// Load events data
		DispatchQueue.main.async {
			if self.showCalendar {
				self.calendarView.reloadData(withAnchor: selectedDate, animation: false, completionHandler: nil)
			}
		}
	}
	
	// Round date to nearest 1 day
	func roundToNearest1d(from date: Date) -> Date? {
		
		let calendar	= Calendar.current
		let components	= calendar.dateComponents([.year, .month, .day], from: date)
		guard let date	= calendar.date(from: components) else { return nil }
		
		return date
	}
}

//**********************************************************************************************************************
// TABLE VIEW DELEGATE AND DATASOURCE (IGNORE THIS)
//**********************************************************************************************************************

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BlankCell", for: indexPath)
		return cell
	}
}

//**********************************************************************************************************************
// JTCALENDAR VIEW DELEGATE AND DATASOURCE
//**********************************************************************************************************************

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
	
	func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
		
		let parameters = ConfigurationParameters(startDate: startDate,
		                                         endDate: endDate,
		                                         numberOfRows: 6,
		                                         calendar: Calendar.current,
		                                         generateInDates: .forAllMonths,
		                                         generateOutDates: .tillEndOfGrid,
		                                         firstDayOfWeek: .sunday)
		return parameters
	}
	
	func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
		
		let myCustomCell = cell as! CalendarCellView
		myCustomCell.label.text = cellState.text
		
		handleCellTextColor(view: cell, cellState: cellState)
		handleCellSelection(view: cell, cellState: cellState)
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
		handleCellTextColor(view: cell, cellState: cellState)
		handleCellSelection(view: cell, cellState: cellState)
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
		handleCellTextColor(view: cell, cellState: cellState)
		handleCellSelection(view: cell, cellState: cellState)
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
		
		// Get selected date
		guard let selectedDate = selectedDate else { return }
		let count = visibleDates.monthDates.count
		let visibleMonthStart = visibleDates.monthDates[0]
		let visibleMonthEnd = visibleDates.monthDates[count - 1]
		
		// If selected date is outside of range for displayed month, select the first day of the month
		if selectedDate < visibleMonthStart || selectedDate > visibleMonthEnd {
			calendar.selectDates([visibleDates.monthDates[0]])
		}
	}
	
	// Function to handle the text color of the calendar
	func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
		
		guard let myCustomCell = view as? CalendarCellView else { return }
		
		if cellState.isSelected {
			
			myCustomCell.label.textColor = UIColor.white
			myCustomCell.label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightThin)
			
		} else {
			
			guard let roundedDate = self.roundToNearest1d(from: cellState.date), let currentDay = self.roundToNearest1d(from: Date()) else { return }
			
			guard cellState.dateBelongsTo == .thisMonth else {
				myCustomCell.label.textColor = UIColor.gray
				myCustomCell.label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightThin)
				return
			}
			
			if roundedDate == currentDay {
				
				myCustomCell.label.textColor = UIColor.blue
				myCustomCell.label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
				
			} else {
				
				myCustomCell.label.textColor = UIColor.black
				myCustomCell.label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightThin)
			}
		}
	}
	
	// Function to handle the calendar selection
	func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
		
		guard let myCustomCell = view as? CalendarCellView else { return }
		
		if cellState.isSelected {
			
			selectedDate = cellState.date
			guard let selectedDate = selectedDate else { return }
			leftBarButton.title = self.monthFormatter.string(from: selectedDate)
			
			myCustomCell.selectionView.isHidden = false
			
		} else {
			
			myCustomCell.selectionView.isHidden = true
		}
	}
}
