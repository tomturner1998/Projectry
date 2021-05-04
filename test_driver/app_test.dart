import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

void main() {
  group('Projectry Student', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test("Title Exists", () async {
      expect(await driver.getText(find.text("Projectry")), "Projectry");
    });

    test("Navigate To Home Page", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byValueKey("EmailField"));
        await driver.enterText("i.am.a.student@uni.com");

        await driver.tap(find.byValueKey("PasswordField"));
        await driver.enterText("Student123");

        await driver.tap(find.byValueKey("SignInButton"));

        expect(await driver.getText(find.text("Browse Projects")),
            "Browse Projects");

        expect(await driver.getText(find.text("Messages")), "Messages");

        expect(await driver.getText(find.text("My Projects")), "My Projects");

        expect(await driver.getText(find.text("Profile")), "Profile");
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("navigate_to_home_summary",
          pretty: true);
    });

    test("Create And Delete Project", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byValueKey("MyProjectsPageButton"));
        await driver.tap(find.byValueKey("CreateProjectButton"));

        await driver.tap(find.byValueKey("CreateProjectTitleInput"));
        await driver.enterText("Test Project Title");
        await driver.tap(find.text("Next"));

        await driver.tap(find.byValueKey("CreateProjectDescriptionInput"));
        await driver.enterText("Test Project Description");
        await driver.tap(find.text("Next"));

        await driver.scrollUntilVisible(
            find.byValueKey("CreateProjectTopicGrid"),
            find.text("Machine Learning"),
            dyScroll: -300.0);
        await driver.tap(find.text("Machine Learning"));
        await driver.tap(find.text("Next"));

        await driver.tap(find.text("Create Project"));

        expect(await driver.getText(find.text("Test Project Title")),
            "Test Project Title");

        await driver.tap(find.text("Test Project Title"));
        await driver.tap(find.byValueKey("MyProjectsDeleteProjectButton"));
        await driver
            .tap(find.byValueKey("MyProjectsDeleteProjectButtonConfirm"));

        await driver.waitForAbsent(find.text("Test Project Title"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("create_and_delete_project_summary",
          pretty: true);
    });

    test("View Profile and Change Preferences", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("ProfilePageButton"));
        await driver.tap(find.byValueKey("ProfilePrefsCards"));

        await driver.scrollUntilVisible(
            find.byValueKey("ChangePrefsListView"), find.text("Statistics"),
            dyScroll: -300.0);

        await driver.tap(find.text("Statistics"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("profile_summary", pretty: true);
    });

    test("Should Open Browse Projects", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("BrowseProjectsButton"));

        await driver.tap(find.byValueKey("BrowseProjectsFiltersButton"));
        await driver.tap(find.byValueKey("TopicFilterDropdown"));
        await driver.scroll(find.byValueKey("TopicFilterDropdown"), 0, -300,
            Duration(milliseconds: 500));
        await driver.tap(find.text("Statistics"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("browse_projects_summary", pretty: true);
    });

    test("Should Use Message Functionality", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("MessagesHomeButton"));

        await driver.tap(find.byType("FloatingActionButton"));

        await driver.scrollUntilVisible(find.byValueKey("MessagesListOfUsers"),
            find.text("Test Supervisor"));
        await driver.tap(find.text("Test Supervisor"));

        await driver.tap(find.byValueKey("ConversationMessageInput"));
        await driver.enterText("Hello!");
        await driver.tap(find.byValueKey("ConversationSendButton"));

        await driver.tap(find.byTooltip('Back'));

        await driver.scroll(
            find.text("Test Supervisor"), 0, 0, Duration(milliseconds: 1000));
        await driver.tap(find.text("Delete Message"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("messaging_summary", pretty: true);
    });

    test("Should sign out", () async {
      await driver.tap(find.byTooltip('Back'));
      await driver.tap(find.byValueKey("SignOutButton"));
    });

    test("Title Exists", () async {
      expect(await driver.getText(find.text("Projectry")), "Projectry");
    });

    test("Navigate To Home Page", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byValueKey("EmailField"));
        await driver.enterText("supervisor@uni.ac.uk");

        await driver.tap(find.byValueKey("PasswordField"));
        await driver.enterText("supervisor");

        await driver.tap(find.byValueKey("SignInButton"));

        expect(await driver.getText(find.text("Supervision Overview")),
            "Supervision Overview");

        expect(await driver.getText(find.text("Projects for Approval")),
            "Projects for Approval");

        expect(await driver.getText(find.text("Messages")), "Messages");

        expect(await driver.getText(find.text("My Projects")), "My Projects");

        expect(await driver.getText(find.text("Profile")), "Profile");
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("supervisor_navigate_to_home_summary",
          pretty: true);
    });

    test("Create And Delete Project", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byValueKey("MyProjectsPageButton"));
        await driver.tap(find.byValueKey("CreateProjectButton"));

        await driver.tap(find.byValueKey("CreateProjectTitleInput"));
        await driver.enterText("Test Project Title");
        await driver.tap(find.text("Next"));

        await driver.tap(find.byValueKey("CreateProjectDescriptionInput"));
        await driver.enterText("Test Project Description");
        await driver.tap(find.text("Next"));

        await driver.scrollUntilVisible(
            find.byValueKey("CreateProjectTopicGrid"),
            find.text("Machine Learning"),
            dyScroll: -300.0);
        await driver.tap(find.text("Machine Learning"));
        await driver.tap(find.text("Next"));

        await driver.tap(find.byValueKey("MyProjectsMaxClaimsInput"));
        await driver.enterText("5");

        await driver.tap(find.text("Create Project"));

        expect(await driver.getText(find.text("Test Project Title")),
            "Test Project Title");

        await driver.tap(find.text("Test Project Title"));
        await driver.tap(find.byValueKey("MyProjectsDeleteProjectButton"));
        await driver
            .tap(find.byValueKey("MyProjectsDeleteProjectButtonConfirm"));

        await driver.waitForAbsent(find.text("Test Project Title"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile(
          "supervisor_create_and_delete_project_summary",
          pretty: true);
    });

    test("View Profile and Change Preferences", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("ProfilePageButton"));
        await driver.tap(find.byValueKey("ProfilePrefsCards"));

        await driver.scrollUntilVisible(
            find.byValueKey("ChangePrefsListView"), find.text("Statistics"),
            dyScroll: -300.0);

        await driver.tap(find.text("Statistics"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("supervisor_profile_summary",
          pretty: true);
    });

    test("Should Use Message Functionality", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("MessagesHomeButton"));

        await driver.tap(find.byType("FloatingActionButton"));
        await driver.scrollUntilVisible(find.byValueKey("MessagesListOfUsers"),
            find.text("Student 123"));
        await driver.tap(find.text("Student 123"));

        await driver.tap(find.byValueKey("ConversationMessageInput"));
        await driver.enterText("Hello!");
        await driver.tap(find.byValueKey("ConversationSendButton"));

        await driver.tap(find.byTooltip('Back'));

        await driver.scroll(find.text("Student 123"), 0, 0,
            Duration(milliseconds: 1000));
        await driver.tap(find.text("Delete Message"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("supervisor_messaging_summary",
          pretty: true);
    });

    test("Should Open Supervision Overview", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("SupervisionOverviewButton"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("supervisor_messaging_summary",
          pretty: true);
    });

    test("Should Open Projects For Approval", () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byTooltip('Back'));

        await driver.tap(find.byValueKey("ProjectsForApprovalButton"));
      });

      final summary = TimelineSummary.summarize(timeline);
      await summary.writeSummaryToFile("supervisor_messaging_summary",
          pretty: true);
    });
  });
}
