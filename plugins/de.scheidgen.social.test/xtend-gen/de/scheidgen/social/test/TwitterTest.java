package de.scheidgen.social.test;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.test.SocialUtil;
import de.scheidgen.social.twitter.Search;
import de.scheidgen.social.twitter.Statuses;
import de.scheidgen.social.twitter.Twitter;
import de.scheidgen.social.twitter.response.TwitterSearchResult;
import de.scheidgen.social.twitter.response.TwitterStatus;
import de.scheidgen.social.twitter.response.TwitterUser;
import de.scheidgen.social.twitter.search.SearchResultType;
import de.scheidgen.social.twitter.search.Tweets;
import de.scheidgen.social.twitter.statuses.Show;
import de.scheidgen.social.twitter.statuses.UserTimeline;
import java.util.List;
import org.eclipse.xtext.xbase.lib.InputOutput;

@SuppressWarnings("all")
public class TwitterTest {
  public static void main(final String[] args) {
    final Profile profile = SocialUtil.openProfile();
    SocialService _twitterService = SocialUtil.getTwitterService(profile);
    final Twitter twitter = Twitter.create(_twitterService);
    Statuses _statuses = twitter.getStatuses();
    UserTimeline _userTimeline = _statuses.getUserTimeline();
    UserTimeline _count = _userTimeline.count(100);
    final List<TwitterStatus> userTimeline = _count.send();
    TwitterStatus _get = userTimeline.get(0);
    final String firstTweetId = _get.getId();
    Statuses _statuses_1 = twitter.getStatuses();
    Show _show = _statuses_1.getShow();
    Show _id = _show.id(firstTweetId);
    final TwitterStatus firstTweet = _id.send();
    TwitterUser _user = firstTweet.getUser();
    String _location = _user.getLocation();
    InputOutput.<String>println(_location);
    Search _search = twitter.getSearch();
    Tweets _tweets = _search.getTweets();
    Tweets _q = _tweets.q("Barack Obama");
    Tweets _resultType = _q.resultType(SearchResultType.popular);
    TwitterSearchResult _send = _resultType.send();
    List<TwitterStatus> _statuses_2 = _send.getStatuses();
    for (final TwitterStatus status : _statuses_2) {
      int _retweetCount = status.getRetweetCount();
      String _plus = ("# " + Integer.valueOf(_retweetCount));
      String _plus_1 = (_plus + ":");
      String _text = status.getText();
      String _plus_2 = (_plus_1 + _text);
      InputOutput.<String>println(_plus_2);
    }
  }
}
