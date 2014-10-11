#!/usr/bin/python
# Calculate hours for the week, format it nicely
# Lauren Caliolio 7/26/2014

"""This will:
    Enter the info from the tickets
    Calculates the total hours worked
    Puts it into the format he wants
"""

"""Tech notes:
    Create class containing variables and functions needed from user input
    Create empty array to store it all
    Run while loop to get info
    Put it in a an easy to read format
"""

prompt = "yes"

class OvertimeHours:
    def __init__(self):
        self.date = ""
        self.ticket_number = ""
        self.time_in = ""
        self.time_out = ""
        self.total = ""
    def get_date(self):
        self.date = raw_input("Enter the date: ")
    def get_ticket_number(self):
        self.ticket_number = raw_input("Enter the ticket number for " + str(self.date) + ": ")
    def get_time_in(self):
        self.time_in = raw_input("Enter time IN on " + str(self.date) + ": ")
    def get_time_out(self):
        self.time_out = raw_input("Enter time OUT on " + str(self.date) + ": ")
    def get_total(self):
        self.total = int(self.time_out) - int(self.time_in)
        print "Total hours worked is " + (str(self.total)) + "."
    def print_hours(self):
            print str(self.ticket_number) \
            + str(self.time_in) \
            + str(self.time_out) \
            + str(self.total)

ot_list = []

# While loop to iterate through yes number of times
while prompt  == "yes":
    OTHours = OvertimeHours() 
    OTHours.get_date()
    OTHours.get_ticket_number()
    OTHours.get_time_in()
    OTHours.get_time_out()
    OTHours.get_total()
    ot_list.append(OTHours)
    prompt = raw_input("Do you have any more hours to enter? Type yes or no: ")

# Set up format for final output
# From http://knowledgestockpile.blogspot.com/2011/01/string-formatting-in-python_09.html

# Put headers in order, align center, and define column width as 13 characters wide
final_format_headers = "{0:^13} {1:^13} {2:^13} {3:^13} {4:^13}" \
    .format("Date", \
    "Ticket Number", \
    "Time In", \
    "Time Out", \
    "Total")

# Grab info from list of data entered, align center, and define column width as 13 characters
final_format_hours = ""
for hours in ot_list:
    final_format_hours = final_format_hours+"{0:^13} {1:^13} {2:^13} {3:^13} {4:^13}" \
        .format(hours.date, \
        hours.ticket_number, \
        hours.time_in, \
        hours.time_out, \
        hours.total)
