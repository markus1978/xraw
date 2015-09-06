package de.scheidgen.social.test;

import de.scheidgen.social.core.SocialService;
import de.scheidgen.social.core.socialstore.Profile;
import de.scheidgen.social.test.SocialUtil;
import de.scheidgen.social.tumblr.Blog;
import de.scheidgen.social.tumblr.Tumblr;
import de.scheidgen.social.tumblr.blog.Info;
import de.scheidgen.social.tumblr.response.TumblrBlog;
import org.eclipse.xtext.xbase.lib.InputOutput;

@SuppressWarnings("all")
public class TumblrTest {
  public static void main(final String[] args) {
    final Profile profile = SocialUtil.openProfile();
    SocialService _tumblrService = SocialUtil.getTumblrService(profile);
    final Tumblr tumblr = Tumblr.create(_tumblrService);
    Blog _blog = tumblr.getBlog();
    Info _info = _blog.getInfo();
    Info _baseHostname = _info.baseHostname("cubemonstergames.tumblr.com");
    final TumblrBlog response = _baseHostname.send();
    String _description = response.getDescription();
    InputOutput.<String>println(_description);
  }
}
