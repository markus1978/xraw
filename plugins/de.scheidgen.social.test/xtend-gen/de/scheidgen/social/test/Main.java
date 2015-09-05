package de.scheidgen.social.test;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.test.SocialUtil;
import de.scheidgen.social.twitter.Twitter;
import de.scheidgen.social.twitter.resources.TwitterTweet;
import de.scheidgen.social.twitter.statuses.UserTimeline;
import java.util.List;
import java.util.function.Consumer;
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
    List<TwitterTweet> _send = _count.send();
    final Consumer<TwitterTweet> _function = (TwitterTweet it) -> {
      String _text = it.getText();
      InputOutput.<String>println(_text);
      InputOutput.println();
    };
    _send.forEach(_function);
  }
}
