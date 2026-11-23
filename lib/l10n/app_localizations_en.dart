// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get continueLabel => 'Continue';

  @override
  String get later => 'Later';

  @override
  String get download => 'Download';

  @override
  String get view => 'View';

  @override
  String get send => 'Send';

  @override
  String get update => 'Update';

  @override
  String get publish => 'Publish';

  @override
  String get discard => 'Discard';

  @override
  String get settings => 'Settings';

  @override
  String get edited => 'edited';

  @override
  String get deletedUser => 'Deleted user';

  @override
  String get untitled => 'Untitled';

  @override
  String get pinned => 'Pinned';

  @override
  String get emptyList => 'Nothing here yet';

  @override
  String get offlineBanner => 'No connection';

  @override
  String get showingCached => 'No internet; showing the last saved version.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutes(int count) {
    return '$count min ago';
  }

  @override
  String timeHours(int count) {
    return '$count h ago';
  }

  @override
  String timeDays(int count) {
    return '$count d ago';
  }

  @override
  String get navFeed => 'Feed';

  @override
  String get navSearch => 'Search';

  @override
  String get navWrite => 'Write';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get typeQuote => 'Quote';

  @override
  String get typeThought => 'Thought';

  @override
  String get typeThesis => 'Thesis';

  @override
  String get typeProject => 'Project';

  @override
  String get typeQuotes => 'Quotes';

  @override
  String get typeThoughts => 'Thoughts';

  @override
  String get typeTheses => 'Theses';

  @override
  String get typeProjects => 'Projects';

  @override
  String get typeQuoteHint => 'Lines from a book or author, plus your note';

  @override
  String get typeThoughtHint => 'What is on your mind, short or long';

  @override
  String get typeThesisHint => 'A reasoned piece arguing an idea';

  @override
  String get typeProjectHint => 'Something you are working on, with images';

  @override
  String get writeWhat => 'What would you like to write?';

  @override
  String get myDrafts => 'My drafts';

  @override
  String get intro1Title => 'Build your own library';

  @override
  String get intro1Body =>
      'Quotes, thoughts, theses and projects. Your profile is a personal library anyone can read.';

  @override
  String get intro2Title => 'Focus on reading';

  @override
  String get intro2Body =>
      'A quiet interface, the font and theme you like. The text comes first.';

  @override
  String get intro3Title => 'Discover and discuss';

  @override
  String get intro3Body =>
      'Browse by type, tag and what is popular; comment, like and save.';

  @override
  String get getStarted => 'Get started';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'New password';

  @override
  String get code => 'Code';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to continue to your library.';

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get signUpSubtitle => 'We will email you a verification code.';

  @override
  String get noAccount => 'No account?';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get and => ' and the ';

  @override
  String get privacyNotice => 'privacy notice';

  @override
  String get acceptSuffix => ' — I have read and accept them.';

  @override
  String get ageConfirm => 'I am at least 16 years old.';

  @override
  String get verifyTitle => 'Verify your email';

  @override
  String verifySubtitle(String email) {
    return 'Enter the code we sent to $email.';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code (${seconds}s)';
  }

  @override
  String get codeResent => 'A new code was sent';

  @override
  String get checkSpam => 'Not there? Check your spam folder.';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle =>
      'Enter your account email and we will send you a code.';

  @override
  String forgotCodeSent(String email) {
    return 'Enter the code sent to $email and your new password.';
  }

  @override
  String get sendCode => 'Send code';

  @override
  String get updatePassword => 'Update password';

  @override
  String get passwordUpdated => 'Your password was updated';

  @override
  String get setupNicknameTitle => 'How should we know you?';

  @override
  String get setupNicknameSubtitle =>
      'Your @nickname is unique and becomes your profile address. Your display name can be anything.';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHelp => '3–20 characters: a-z, 0-9, _ and .';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHelp => 'Shown on your profile and posts';

  @override
  String get setupProfileTitle => 'Complete your profile';

  @override
  String get setupProfileSubtitle =>
      'Add a photo and a short bio. You can also do it later.';

  @override
  String get bio => 'Bio';

  @override
  String get bioHelp => 'Up to 160 characters';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get cropAvatar => 'Profile photo';

  @override
  String get cropCover => 'Cover image';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errOffline => 'No internet connection.';

  @override
  String get errRequired => 'This field is required';

  @override
  String get errInvalidEmail => 'Enter a valid email address';

  @override
  String errPasswordShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get errInvalidCredentials => 'Wrong email or password';

  @override
  String get errEmailNotConfirmed => 'Your email is not verified yet';

  @override
  String get errEmailExists => 'An account with this email already exists';

  @override
  String get errWeakPassword => 'Password is too weak';

  @override
  String get errSamePassword => 'The new password must be different';

  @override
  String get errCodeInvalid => 'The code is wrong or has expired';

  @override
  String get errRateLimit => 'Too many attempts. Please try again later.';

  @override
  String get errBanned => 'This account was closed for breaking the rules.';

  @override
  String get errAcceptRequired => 'Tick both boxes to continue';

  @override
  String get errNicknameTaken => 'This nickname is taken';

  @override
  String get errNicknameReserved =>
      'This nickname was recently released and is unavailable for 30 days';

  @override
  String get errNicknameTooSoon =>
      'You can change your nickname once every 30 days';

  @override
  String get errTooManyTags => 'You can add up to 5 tags';

  @override
  String get errTooManyImages => 'A post can have up to 5 images';

  @override
  String get errTagTooLong => 'A tag can be up to 30 characters';

  @override
  String get errTitleRequired => 'Add a title to publish';

  @override
  String get errBodyRequired => 'Write something to publish';

  @override
  String get errNotAllowed => 'You are not allowed to do this';

  @override
  String get errDuplicate => 'This already exists';

  @override
  String get errInvalidInput => 'The input is not valid';

  @override
  String get errUpload => 'The image could not be uploaded';

  @override
  String get updateTitle => 'A new version is available';

  @override
  String updateAvailable(String version) {
    return 'Peerless $version is ready to download and install.';
  }

  @override
  String updateRequired(String version) {
    return 'You need to install Peerless $version to continue.';
  }

  @override
  String get sort => 'Sort';

  @override
  String get sortLatest => 'Latest';

  @override
  String get sortPopular => 'Popular';

  @override
  String get tabAll => 'All';

  @override
  String get popularHint => 'Most liked posts of the last 7 days';

  @override
  String get emptyFeed => 'No posts yet';

  @override
  String get emptyPopular => 'No popular posts this week yet';

  @override
  String get emptyFeedHint =>
      'Be the first: tap the Write button in the middle.';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get font => 'Font';

  @override
  String get textSize => 'Text size';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get lineSpacing => 'Line spacing';

  @override
  String get lineNarrow => 'Narrow';

  @override
  String get lineNormal => 'Normal';

  @override
  String get lineWide => 'Wide';

  @override
  String get readingTheme => 'Reading theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Unlike';

  @override
  String get comment => 'Comment';

  @override
  String get bookmark => 'Save';

  @override
  String get removeBookmark => 'Remove from saved';

  @override
  String get bookmarkAdded => 'Saved';

  @override
  String get bookmarkRemoved => 'Removed from saved';

  @override
  String get pinToProfile => 'Pin to my profile';

  @override
  String get unpin => 'Unpin';

  @override
  String get pinnedDone => 'Pinned to your profile';

  @override
  String get unpinned => 'Unpinned';

  @override
  String get deletePostTitle => 'Delete this post?';

  @override
  String get deletePostBody =>
      'This cannot be undone; comments and likes are deleted too.';

  @override
  String get postDeleted => 'Post deleted';

  @override
  String get report => 'Report';

  @override
  String get viewProfile => 'View profile';

  @override
  String get personalNote => 'Personal note';

  @override
  String get postNotFound => 'Post not found';

  @override
  String get postNotFoundHint =>
      'It may have been deleted, removed, or is not available to you.';

  @override
  String get postRemovedNotice =>
      'This post was removed for breaking the rules. Only you can see it.';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'No comments',
    );
    return '$_temp0';
  }

  @override
  String get noComments => 'Be the first to comment.';

  @override
  String get reply => 'Reply';

  @override
  String get writeComment => 'Write a comment…';

  @override
  String replyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get editComment => 'Edit comment';

  @override
  String get deleteCommentTitle => 'Delete this comment?';

  @override
  String get reportSentTitle => 'Thank you';

  @override
  String get reportSentBody =>
      'Sent to the admins. The necessary action will be taken.';

  @override
  String get reportAlready => 'You have already reported this';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String blockConfirmTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockConfirmBody =>
      'You will not see their posts or comments. They cannot comment on, like or @mention your posts.';

  @override
  String blocked(String name) {
    return '$name was blocked';
  }

  @override
  String unblocked(String name) {
    return '$name was unblocked';
  }

  @override
  String get youBlockedUser => 'You blocked this person';

  @override
  String get youBlockedUserHint =>
      'Unblock them from the menu to see their posts.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get bookmarks => 'Saved';

  @override
  String get userNotFound => 'User not found';

  @override
  String get emptyLibrary => 'This library is empty for now';

  @override
  String get emptyMyLibrary => 'Your library is empty. Write your first post!';

  @override
  String get emptyType => 'No posts of this type';

  @override
  String get emptyBookmarks => 'Nothing saved yet';

  @override
  String get emptyBookmarksHint =>
      'Tap the bookmark icon while reading. Only you can see this list.';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get changeCover => 'Change cover';

  @override
  String get nicknameChangeRule =>
      'You can change your nickname every 30 days; the old one is held for 30 days.';

  @override
  String nicknameNextChange(String date) {
    return 'You can change your nickname after $date.';
  }

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get titleHint => 'Title';

  @override
  String get bodyHint => 'Start writing…';

  @override
  String get quoteBodyHint => 'Write the quote here…';

  @override
  String get personalNoteHint => 'Your note shown under the quote (optional)';

  @override
  String get addCover => 'Add cover';

  @override
  String get gallery => 'Image gallery';

  @override
  String get galleryOnlyProject =>
      'Galleries are only for projects; remove gallery images first.';

  @override
  String get tags => 'Tags';

  @override
  String get tagHint => 'Add a tag (comma or space)';

  @override
  String tagRule(int max) {
    return 'Up to $max tags; existing tags are suggested.';
  }

  @override
  String imageLimitInfo(int count, int max) {
    return 'Images: $count/$max (cover + inline + gallery)';
  }

  @override
  String get saving => 'Saving…';

  @override
  String get savedDraft => 'Draft saved';

  @override
  String get saveFailed => 'Could not save';

  @override
  String get published => 'Published';

  @override
  String get updated => 'Updated';

  @override
  String get deleteDraftTitle => 'Delete this draft?';

  @override
  String get discardChangesTitle => 'Unsaved changes';

  @override
  String get discardChangesBody => 'If you leave, your changes will be lost.';

  @override
  String get noDrafts => 'No drafts';

  @override
  String get noDraftsHint =>
      'What you write is saved as a draft automatically.';

  @override
  String get fmtHeading => 'Heading';

  @override
  String get fmtBold => 'Bold';

  @override
  String get fmtItalic => 'Italic';

  @override
  String get fmtQuote => 'Quote block';

  @override
  String get fmtBullets => 'Bulleted list';

  @override
  String get fmtNumbers => 'Numbered list';

  @override
  String get addLink => 'Add link';

  @override
  String get addImage => 'Add image';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get searchHint => 'Search people or posts';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get popularThisWeek => 'Popular this week';

  @override
  String get people => 'People';

  @override
  String get posts => 'Posts';

  @override
  String get noResults => 'No results found';

  @override
  String get noPostResults => 'No posts match this search';

  @override
  String notifComment(String user) {
    return '$user commented on your post';
  }

  @override
  String notifReply(String user) {
    return '$user replied to your comment';
  }

  @override
  String notifLike(String user) {
    return '$user liked your post';
  }

  @override
  String notifMention(String user) {
    return '$user mentioned you in a comment';
  }

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsHint =>
      'Comments, replies, likes and mentions appear here.';

  @override
  String get moderationNoticeTitle => 'Moderation notice';

  @override
  String get moderationRemoved =>
      'Your content was removed for breaking the rules.';

  @override
  String get moderationWarned => 'Your account received an official warning.';

  @override
  String get moderationBanned => 'Your account was permanently closed.';

  @override
  String get moderationGeneric =>
      'There is a moderation notice about your account.';

  @override
  String get adminNote => 'Admin note';

  @override
  String get viewPost => 'View post';

  @override
  String get reports => 'Reports';

  @override
  String get appVersion => 'App version';

  @override
  String get noOpenReports => 'No open reports';

  @override
  String get reportTargetPost => 'Post';

  @override
  String get reportTargetComment => 'Comment';

  @override
  String get reportTargetProfile => 'Profile';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get removeContent => 'Remove content';

  @override
  String get warn => 'Warn';

  @override
  String get ban => 'Permanent ban';

  @override
  String get adminNoteOptional => 'Note (optional, shown to the user)';

  @override
  String get moderationDone => 'Action applied';

  @override
  String get appVersionHelp =>
      'Users on an older version than \"latest\" see an update prompt; below \"minimum\" they must update to continue.';

  @override
  String get latestVersion => 'Latest version';

  @override
  String get minVersion => 'Minimum version';

  @override
  String get apkUrl => 'APK download link';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsBlocked => 'Blocked users';

  @override
  String get settingsAbout => 'About';

  @override
  String get changeEmail => 'Change email';

  @override
  String get newEmail => 'New email';

  @override
  String emailChangeCodeSent(String email) {
    return 'Enter the code sent to $email.';
  }

  @override
  String get emailChanged => 'Your email was changed';

  @override
  String get changePassword => 'Change password';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountHint => 'Final after 30 days';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'Your account and all your data will be permanently deleted in 30 days. Signing in again during this time cancels the request.';

  @override
  String get deleteAccountRequested =>
      'Deletion requested. Sign in within 30 days to cancel.';

  @override
  String get notifSettingComment => 'Comments on my posts';

  @override
  String get notifSettingReply => 'Replies to my comments';

  @override
  String get notifSettingLike => 'Likes on my posts';

  @override
  String get notifSettingMention => '@mentions';

  @override
  String get notifSettingModeration =>
      'Moderation notices (warnings, removals) are always shown in the app.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get theme => 'Theme';

  @override
  String get noBlockedUsers => 'You have not blocked anyone';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get contact => 'Contact';

  @override
  String get legalTurkishOnly =>
      'This text is currently available in Turkish only.';
}
