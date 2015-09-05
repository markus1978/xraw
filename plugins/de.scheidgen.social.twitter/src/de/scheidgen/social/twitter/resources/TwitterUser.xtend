package de.scheidgen.social.twitter.resources

import de.scheidgen.social.core.annotations.Response
import de.scheidgen.social.core.annotations.Name
import de.scheidgen.social.core.annotations.WithConverter
import java.net.URL
import de.scheidgen.social.core.annotations.Converter
import java.util.Date

class UrlConverter implements Converter<URL> {
	override convert(String value) {
		return new URL(value)
	}
}

@Response
class TwitterUser {
    @Name("profile_sidebar_fill_color") String profileSidebarFillColor
    @Name("profile_sidebar_border_color") String profileSidebarBorderColor
    @Name("profile_background_tile") boolean profileBackgroundTile = false
    String name
    @Name("profile_image_url") @WithConverter(UrlConverter) URL profileImageUrl
    @Name("created_at") @WithConverter(TwitterDateConverter) Date createdAt
    String location
    @Name("follow_request_sent") boolean followRequestSent = false
    @Name("profile_link_color") String profileLinkColor
    @Name("is_translator") boolean isTranslator = false
    @Name("id_str") String id
    Object entities
    @Name("default_profile") boolean defaultProfile = true
    @Name("contributors_enabled") boolean contributorsEnabled = true
    @Name("favourites_count") int favouritesCount
    @WithConverter(UrlConverter) URL url
    @Name("profile_image_url_https") @WithConverter(UrlConverter) URL profileImageUrlHttps
    @Name("utc_offset") int utcOffset
    @Name("profile_use_background_image") boolean profileUseBackgroundImage = false
    @Name("listed_count") int listedCount
    @Name("profile_text_color") String profileTextColor
    String lang
    @Name("followers_count") int followersCount
    @Name("protected") boolean isProtected = false
    Object notifications
    @Name("profile_background_image_url_https") @WithConverter(UrlConverter) URL profileBackgroundImageUrlHttps
    @Name("profile_background_color") String profileBackgroundColor
    boolean verified
    @Name("geo_enabled") boolean geoEnabled = false
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