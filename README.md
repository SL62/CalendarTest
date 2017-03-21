# CalendarTest
Potential UI bug with JTAppleCalendar
-------------------------------------
When calendar view appears, everything initially appears fine.
Upon cell selection for the first time, the view visibly shifts very slightly (approx 2px to the right and 2px down).
Selection of subsequent cells no longer causes the shift.
Howevever, after hiding the calendar and re-showing it, the first cell selection again causes the view to shift slightly.
Everything else works as expected, e.g. scrolling between different months.
