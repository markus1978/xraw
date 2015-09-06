package de.scheidgen.social.twitter.response

import de.scheidgen.social.annotations.Name
import de.scheidgen.social.annotations.Response
import de.scheidgen.social.annotations.UrlConverter
import de.scheidgen.social.annotations.WithConverter
import de.scheidgen.social.twitter.converter.TwitterColor
import de.scheidgen.social.twitter.converter.TwitterColorConverter
import de.scheidgen.social.twitter.converter.TwitterDateConverter
import java.net.URL
import java.util.Date

@Response
class TwitterUser {
    @WithConverter(TwitterColorConverter) TwitterColor profile_sidebar_fill_color
    @WithConverter(TwitterColorConverter) TwitterColor profile_sidebar_border_color
    boolean profile_background_tile = false
    String name
    @WithConverter(UrlConverter) URL profile_image_url
    @WithConverter(TwitterDateConverter) Date created_at
    String location
    boolean follow_request_sent = false
    @WithConverter(TwitterColorConverter) TwitterColor profile_link_color
    boolean is_translator = false
    @Name("id_str") String id
    Object entities
    boolean default_profile = true
    boolean contributors_enabled = true
    int favourites_count
    @WithConverter(UrlConverter) URL url
    @WithConverter(UrlConverter) URL profile_image_url_https
    @Name("utc_offset") int utcOffset
    boolean profile_use_background_image = false
    int listed_count
    @WithConverter(TwitterColorConverter) TwitterColor profile_text_color
    String lang
    int followers_count
    @Name("protected") boolean isProtected = false
    Object notifications
    @WithConverter(UrlConverter) URL profile_background_image_url_https
    @WithConverter(TwitterColorConverter) TwitterColor profile_background_color
    boolean verified
    boolean geo_enabled = false
    String time_zone
    String description
    boolean default_profile_image = false
    @WithConverter(UrlConverter) URL profile_background_image_url
    int statuses_count
    int friends_count
    boolean following = false
    boolean show_all_inline_media = false
    String screen_name
}