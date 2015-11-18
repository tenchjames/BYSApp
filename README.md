# BYSApp
========
## Brunswick Youth Sports Baseball / Softball app

### Purpose
This app was created to fill a gap for the little leage coaches and parents/players of the Brunswick Youth Sports organization.
However the app could has the ability to be expanded to allow others to use the app as well.

### The Problem
Currently coaches are doing a very manual process for updating game scores and tracking winners. After each game the home team coach
is to send an email to the commission of the league with the results of the game. The commissioner then compiles the results. 
From all of the emails received, the commissioner loads an excel spreadsheet and sends out updates with league standings and 
game outcomes. The entire process is manual, and the league updates do not come with much frequency.

### Goals
The goal of this app is to automate some of the work to compile the game scores and keep track of league standings. Although there 
are other sports type of apps on the market, most of them come with added complexity that is not needed for basic set up and tracking 
required by the league. This app gives the commissioner an easy way to add teams, update coach information. It also gives coaches 
a central location to update scores and game results. Parents and other users can see league results in near real time compared 
to the current process.


### Udacity Testing
two test accounts have been created to test the application

userid: test
password: password

This user id can be used for general use of the app to view teams scores and change leagues etc

userid: testcommissioner
password: password

This user id can be used to test the commissioner section of the site and change game scores. 
This user id is also in the role of coach over the cardinals team in the test league. They should 
be able to modifiy game scores related to the Cardinals team. Home team coach is responsible for
updating game scores. Away team coach has confirmation role after Home Team coach has updated the score

userid: testadmin
password: password

**added this role to version 2. The admin role is in charge of creating leagues.

In addition, testing can be done by setting up any new account or by logging in with facebook.


### App usage
#### Login view
Users must log into the site. the site uses Parse for all of its data storage. Enter a user id and password to login, or click 
sign up to create a new account.

#### Loading Screen / League View
Upon logging in the app will check the user preferences to determine the last time the user synced up with parse. If the 
login is outside of the predefined time the app will download league data for their currently selected league. The sync timer 
was put in place to limit calls to the parse api, and reduce unnecessary downloads since the site refresh time is not 100% 
real time and does not need to be.

If a user has logged in recently, the app will pull it's league info from core data instead of going to parse.

At the top right of the screen the user can click the League button to change the league they are viewing. 

Selecting a team from the table view will transition the user to a team view that shows the teams schedule including game scores 
with wins and losses. 
*** If the user is in the commissioner role, they have the ability to transition to the admin panel. To show the button triple 
tap in the league name area and it will unhide the admin button.

#### Team View
Shows the schedule for the selected team and any game scores.
** If a user has the role of coach and is the coach of the selected team, the can click on one of the games and go into edit mode.
** Coach admin is controlled by being the coach of the team and email address. Commissioner of the league must ensure 
email address for coaches is valid and will be used by the coach when using the app.

#### Schedule Tab
From the tab controller, selecting the schedule tab will bring up the schedule for the entire league

#### Admin Tableview
Select a admin action

#### Admin views
All the admin views allow the commissioner to add each component to the app (Coaches, Games, Teams, Leagues)
Special note - Admin is controlled by commissioner email. Commissioner of a league can only edit teams and games that 
are related via the commissioner email.

# Udacity project requirements
## Readme file
Does the app contain a read me file? This is it

# Building the app
The app relies on the parse library to function. To build the app, the parse files must be included

## Readme description
Does the app tell the user how to use the app? See above

## Multiple user interface screens
Check

## Control elements
Does the app use more than one type of control? Yes - sliders, switches, buttons, custom views

## App networking
Parse api and all parse calls are in a singleton shared class

## Networking
Does the app show networking activity? yes loading scrren while data is loading, and prompt messages when user completes tasks

## Core data
yes the app uses core data

## Functions
The app runs without crashing


