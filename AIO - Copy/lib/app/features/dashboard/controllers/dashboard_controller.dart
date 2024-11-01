part of dashboard;

class DashboardController extends GetxController {
  final scafoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '545461705793-3v0101rqbcp0hqkeiqt0ohca9me9d0b3.apps.googleusercontent.com',
  );

  // Profile data - updated dynamically after Google sign-in
  final Rx<UserProfileData?> userProfile = Rx<UserProfileData?>(null);

  // Task data
  final dataTask = const TaskProgressData(totalTask: 5, totalCompleted: 1);

  // Google user account data
  Rx<GoogleSignInAccount?> user = Rx<GoogleSignInAccount?>(null);

  // Dark mode toggle
  RxBool isDarkMode = false.obs;

  // Task data examples
  final taskInProgress = [
    CardTaskData(
      label: "Determine meeting schedule",
      jobDesk: "System Analyst",
      dueDate: DateTime.now().add(const Duration(minutes: 50)),
    ),
    CardTaskData(
      label: "Personal branding",
      jobDesk: "Marketing",
      dueDate: DateTime.now().add(const Duration(hours: 4)),
    ),
    CardTaskData(
      label: "UI UX",
      jobDesk: "Design",
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    CardTaskData(
      label: "Determine meeting schedule",
      jobDesk: "System Analyst",
      dueDate: DateTime.now().add(const Duration(minutes: 50)),
    ),
  ];

  // Weekly task data examples
  final weeklyTask = [
    ListTaskAssignedData(
      icon: const Icon(EvaIcons.monitor, color: Colors.blueGrey),
      label: "Slicing UI",
      jobDesk: "Programmer",
      assignTo: "Alex Ferguso",
      editDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ListTaskAssignedData(
      icon: const Icon(EvaIcons.star, color: Colors.amber),
      label: "Personal branding",
      jobDesk: "Marketing",
      assignTo: "Justin Beck",
      editDate: DateTime.now().subtract(const Duration(days: 50)),
    ),
    const ListTaskAssignedData(
      icon: Icon(EvaIcons.colorPalette, color: Colors.blue),
      label: "UI UX ",
      jobDesk: "Design",
    ),
    const ListTaskAssignedData(
      icon: Icon(EvaIcons.pieChart, color: Colors.redAccent),
      label: "Determine meeting schedule ",
      jobDesk: "System Analyst",
    ),
  ];

  // Task group data examples
  final taskGroup = [
    [
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 2, hours: 10)),
        label: "5 posts on Instagram",
        jobdesk: "Marketing",
      ),
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 2, hours: 11)),
        label: "Platform Concept",
        jobdesk: "Animation",
      ),
    ],
    [
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 4, hours: 5)),
        label: "UI UX Marketplace",
        jobdesk: "Design",
      ),
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 4, hours: 6)),
        label: "Create Post For App",
        jobdesk: "Marketing",
      ),
    ],
    [
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 6, hours: 5)),
        label: "2 Posts on Facebook",
        jobdesk: "Marketing",
      ),
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 6, hours: 6)),
        label: "Create Icon App",
        jobdesk: "Design",
      ),
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 6, hours: 8)),
        label: "Fixing Error Payment",
        jobdesk: "Programmer",
      ),
      ListTaskDateData(
        date: DateTime.now().add(const Duration(days: 6, hours: 10)),
        label: "Create Form Interview",
        jobdesk: "System Analyst",
      ),
    ]
  ];

  DashboardController() {
    _initializeGoogleSignIn();
  }

  // Initialize Google Sign-In
  void _initializeGoogleSignIn() async {
    debugPrint("Initializing Google Sign-In...");
    _googleSignIn.onCurrentUserChanged.listen((account) {
      user.value = account;
      debugPrint("User signed in: ${account?.displayName ?? "None"}");
      if (account != null) {
        userProfile.value = UserProfileData(
          image: account.photoUrl != null ? NetworkImage(account.photoUrl!) : AssetImage(ImageRasterPath.man) as ImageProvider,
          name: account.displayName ?? "User",
          jobDesk: account.email,
        );
      } else {
        userProfile.value = null;
      }
    });
    await _googleSignIn.signInSilently();  // Attempt to sign in silently
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      debugPrint("Attempting Google Sign-In...");
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint("Google Sign-In error: $error");
    }
  }

  // Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      debugPrint("Attempting to sign out...");
      await _googleSignIn.disconnect();
      user.value = null;
      userProfile.value = null;
    } catch (error) {
      debugPrint("Google Sign-Out error: $error");
    }
  }

  // Method to toggle dark mode
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
  }

  void onPressedProfil() {}

  void onSelectedMainMenu(int index, SelectionButtonData value) {}

  void onPressedTask(int index, ListTaskAssignedData data) {}
  void onPressedAssignTask(int index, ListTaskAssignedData data) {}
  void onPressedMemberTask(int index, ListTaskAssignedData data) {}
  void onPressedCalendar() {}
  void onPressedTaskGroup(int index, ListTaskDateData data) {}

  void openDrawer() {
    scafoldKey.currentState?.openDrawer();
  }
}
