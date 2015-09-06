package de.scheidgen.social.test;

import de.scheidgen.social.script.SocialScript;
import de.scheidgen.social.tumblr.Blog;
import de.scheidgen.social.tumblr.Tumblr;
import de.scheidgen.social.tumblr.blog.Info;
import de.scheidgen.social.tumblr.response.TumblrBlog;
import org.eclipse.xtext.xbase.lib.InputOutput;

@SuppressWarnings("all")
public class TumblrTest {
  public static void main(final String[] args) {
    SocialScript _createWithStore = SocialScript.createWithStore("data/store.xmi");
    final Tumblr tumblr = _createWithStore.<Tumblr>serviceWithLogin(Tumblr.class, "markus");
    Blog _blog = tumblr.getBlog();
    Info _info = _blog.getInfo();
    Info _baseHostname = _info.baseHostname("cubemonstergames.tumblr.com");
    final TumblrBlog response = _baseHostname.send();
    String _description = response.getDescription();
    InputOutput.<String>println(_description);
  }
}
