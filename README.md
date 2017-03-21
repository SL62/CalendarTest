# CalendarTest
Potential UI bug with JTAppleCalendar
-------------------------------------
1. When calendar view first appears, everything looks fine.
2. Upon cell selection for the first time, the whole calendar view shifts slightly (approx 2px to the right and 2px down).
3. Selection of subsequent cells does not cause further shifting.
4. After hiding the calendar view and re-showing it, the first cell selection again causes the view to shift slightly.
5. Everything else works as expected, e.g. scrolling between different months.

![alt text](https://github.com/SL62/CalendarTest/blob/master/Calendar1.gif "Calendar Test GIF")
