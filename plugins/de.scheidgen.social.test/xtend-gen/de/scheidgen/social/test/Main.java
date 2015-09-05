package de.scheidgen.social.test;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.test.SocialUtil;
import de.scheidgen.social.twitter.Twitter;
import de.scheidgen.social.twitter.resources.TwitterTweet;
import de.scheidgen.social.twitter.resources.TwitterUser;
import de.scheidgen.social.twitter.statuses.Show;
import de.scheidgen.social.twitter.statuses.UserTimeline;
import java.util.List;
import org.eclipse.xtext.xbase.lib.InputOutput;

@SuppressWarnings("all")
public class Main {
  public static void main(final String[] args) {
    final Profile profile = SocialUtil.openProfile();
    SocialService _twitterService = SocialUtil.getTwitterService(profile);
    final Twitter twitter = Twitter.get(_twitterService);
    Twitter.Statuses _statuses = twitter.getStatuses();
    UserTimeline _userTimeline = _statuses.getUserTimeline();
    UserTimeline _count = _userTimeline.count(100);
    final List<TwitterTweet> userTimeline = _count.send();
    TwitterTweet _get = userTimeline.get(0);
    final String firstTweetId = _get.getId();
    Twitter.Statuses _statuses_1 = twitter.getStatuses();
    Show _show = _statuses_1.getShow();
    Show _id = _show.id(firstTweetId);
    final TwitterTweet firstTweet = _id.send();
    TwitterUser _user = firstTweet.getUser();
    String _location = _user.getLocation();
    InputOutput.<String>println(_location);
  }
}
