package de.scheidgen.xraw.apis.youtube.resources

import de.scheidgen.xraw.annotations.JSON
import de.scheidgen.xraw.annotations.WithConverter
import de.scheidgen.xraw.apis.youtube.YouTubeDateConverter
import java.util.Date
import java.util.List
import java.util.Map

@JSON
class YouTubeVideos extends AbstractYouTubeResource {
	/**
	 * The ID that YouTube uses to uniquely identify the video.
	 */
	String id
	
	/**
	 * The <code>snippet</code> object contains basic details about the video, such as its title, description, and category.
	 */
	YouTubeVideosSnippet snippet
	
	/**
	 * The <code>contentDetails</code> object contains information about the video content, including the length of the video and an indication of whether captions are available for the video.
	 */
	YouTubeVideosContentDetails contentDetails
	
	/**
	 * The <code>status</code> object contains information about the video's uploading, processing, and privacy statuses.
	 */
	YouTubeVideosStatus status
	
	/**
	 * The <code>statistics</code> object contains statistics about the video.
	 */
	YouTubeVideosStatistics statistics
	
	/**
	 * The <code>player</code> object contains information that you would use to play the video in an embedded player.
	 */
	YouTubeVideosPlayer player
	
	/**
	 * The <code>topicDetails</code> object encapsulates information about <a href="http://www.freebase.com">Freebase</a> topics associated with the video.
	 */
	YouTubeVideosTopicDetails topicDetails
	
	/**
	 * The <code>recordingDetails</code> object encapsulates information about the location, date and address where the video was recorded.
	 */
	YouTubeVideosRecordingDetails recordingDetails
	
	/**
	 * The <code>fileDetails</code> object encapsulates information about the video file that was uploaded to YouTube, including the file's resolution, duration, audio and video codecs, stream bitrates, and more. This data can only be retrieved by the video owner.<br><br> The <code>fileDetails</code> object will only be returned if the <code><a href="#processingDetails.fileDetailsAvailability">processingDetails.fileAvailability</a></code> property has a value of <code>available</code>.
	 */
	YouTubeVideosFileDetails fileDetails
	
	/**
	 * The <code>processingDetails</code> object encapsulates information about YouTube's progress in processing the uploaded video file. The properties in the object identify the current processing status and an estimate of the time remaining until YouTube finishes processing the video. This part also indicates whether different types of data or content, such as file details or thumbnail images, are available for the video.<br><br> The <code>processingProgress</code> object is designed to be polled so that the video uploaded can track the progress that YouTube has made in processing the uploaded video file. This data can only be retrieved by the video owner.
	 */
	YouTubeVideosProcessingDetails processingDetails
	
	/**
	 * The <code>suggestions</code> object encapsulates suggestions that identify opportunities to improve the video quality or the metadata for the uploaded video. This data can only be retrieved by the video owner. <br><br> The <code>suggestions</code> object will only be returned if the <code><a href="#processingDetails.tagSuggestionsAvailability">processingDetails.tagSuggestionsAvailability</a></code> property or the <code><a href="#processingDetails.editorSuggestionsAvailability">processingDetails.editorSuggestionsAvailability</a></code> property has a value of <code>available</code>.
	 */
	YouTubeVideosSuggestions suggestions
	
	/**
	 * The <code>liveStreamingDetails</code> object contains metadata about a live video broadcast. The object will only be present in a <code>video</code> resource if the video is an upcoming, live, or completed live broadcast.
	 */
	YouTubeVideosLiveStreamingDetails liveStreamingDetails
	
}

@JSON
class YouTubeVideosSnippet {
	/**
	 * The date and time that the video was published. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date publishedAt
	
	/**
	 * The ID that YouTube uses to uniquely identify the channel that the video was uploaded to.
	 */
	String channelId
	
	/**
	 * The video's title. The property value has a maximum length of 100 characters and may contain all valid UTF-8 characters except <b>&lt;</b> and <b>&gt;</b>. You must set a value for this property if you call the <code>videos.update</code> method and are updating the <code><a href="/youtube/v3/docs/videos#snippet">snippet</a></code> part of a <code>video</code> resource.
	 */
	String title
	
	/**
	 * The video's description. The property value has a maximum length of 5000 bytes and may contain all valid UTF-8 characters except <b>&lt;</b> and <b>&gt;</b>.
	 */
	String description
	
	/**
	 * A map of thumbnail images associated with the video. For each object in the map, the key is the name of the thumbnail image, and the value is an object that contains other information about the thumbnail.<br/><br/>Valid key values are:
	 <ul>
	  <li><code>default</code> – The default thumbnail image for this resource. The default thumbnail for a video – or a resource that refers to a video, such as a playlist item or search result – is 120px wide and 90px tall. The default thumbnail for a channel is 88px wide and 88px tall.</li>
	  <li><code>medium</code> – A higher resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 320px wide and 180px tall. For a channel, this image is 240px wide and 240px tall.</li>
	  <li><code>high</code> – A high resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 480px wide and 360px tall. For a channel, this image is 800px wide and 800px tall.</li>
	 </ul>
	 */
	Map<String, YouTubeVideosSnippetThumbnails> thumbnails
	
	/**
	 * Channel title for the channel that the video belongs to.
	 */
	String channelTitle
	
	/**
	 * A list of keyword tags associated with the video. Tags may contain spaces. The property value has a maximum length of 500 characters. Note the following rules regarding the way the character limit is calculated:
	 <ul>
	  <li>The property value is a list, and commas between items in the list count toward the limit.</li>
	  <li>If a tag contains a space, the API server handles the tag value as though it were wrapped in quotation marks, and the quotation marks count toward the character limit. So, for the purposes of character limits, the tag <b>Foo-Baz</b> contains seven characters, but the tag <b>Foo Baz</b> contains nine characters.</li>
	 </ul>
	 */
	List<String> tags
	
	/**
	 * The YouTube <a href="/youtube/v3/docs/videoCategories/list">video category</a> associated with the video. You must set a value for this property if you call the <code>videos.update</code> method and are updating the <code><a href="/youtube/v3/docs/videos#snippet">snippet</a></code> part of a <code>video</code> resource.
	 */
	String categoryId
	
	/**
	 * Indicates if the video is an upcoming/active live broadcast. Or it's "none" if the video is not an upcoming/active live broadcast.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>live</code></li> 
	  <li><code>none</code></li> 
	  <li><code>upcoming</code></li> 
	 </ul>
	 */
	String liveBroadcastContent
	
}

@JSON
class YouTubeVideosSnippetThumbnails {
	/**
	 * The image's URL.
	 */
	String url
	
	/**
	 * The image's width.
	 */
	int width
	
	/**
	 * The image's height.
	 */
	int height
	
}

@JSON
class YouTubeVideosContentDetails {
	/**
	 * The length of the video. The tag value is an <a href="//en.wikipedia.org/wiki/ISO_8601#Durations">ISO 8601</a> duration. For example, for a video that is at least one minute long and less than one hour long, the duration is in the format <code>PT#M#S</code>, in which the letters <code>PT</code> indicate that the value specifies a period of time, and the letters <code>M</code> and <code>S</code> refer to length in minutes and seconds, respectively. The <code>#</code> characters preceding the <code>M</code> and <code>S</code> letters are both integers that specify the number of minutes (or seconds) of the video. For example, a value of <code>PT15M33S</code> indicates that the video is 15 minutes and 33 seconds long.<br><br>If the video is at least one hour long, the duration is in the format <code>PT#H#M#S</code>, in which the <code>#</code> preceding the letter <code>H</code> specifies the length of the video in hours and all of the other details are the same as described above. If the video is at least one day long, the letters <code>P</code> and <code>T</code> are separated, and the value's format is <code>P#DT#H#M#S</code>. Please refer to the ISO 8601 specification for complete details.
	 */
	String duration
	
	/**
	 * Indicates whether the video is available in 3D or in 2D.
	 */
	String dimension
	
	/**
	 * Indicates whether the video is available in high definition (<code>HD</code>) or only in standard definition.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>hd</code></li> 
	  <li><code>sd</code></li> 
	 </ul>
	 */
	String definition
	
	/**
	 * Indicates whether captions are available for the video.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>false</code></li> 
	  <li><code>true</code></li> 
	 </ul>
	 */
	String caption
	
	/**
	 * Indicates whether the video represents licensed content, which means that the content was uploaded to a channel linked to a YouTube content partner and then claimed by that partner.
	 */
	boolean licensedContent
	
	/**
	 * The <code>regionRestriction</code> object contains information about the countries where a video is (or is not) viewable. The object will contain either the <code>contentDetails.regionRestriction.allowed</code> property or the <code>contentDetails.regionRestriction.blocked</code> property.
	 */
	YouTubeVideosContentDetailsRegionRestriction regionRestriction
	
	/**
	 * Specifies the ratings that the video received under various rating schemes.
	 */
	YouTubeVideosContentDetailsContentRating contentRating
	
}

@JSON
class YouTubeVideosContentDetailsRegionRestriction {
	/**
	 * A list of region codes that identify countries where the video is viewable. If this property is present and a country is not listed in its value, then the video is blocked from appearing in that country. If this property is present and contains an empty list, the video is blocked in all countries.
	 */
	List<String> allowed
	
	/**
	 * A list of region codes that identify countries where the video is blocked. If this property is present and a country is not listed in its value, then the video is viewable in that country. If this property is present and contains an empty list, the video is viewable in all countries.
	 */
	List<String> blocked
	
}

@JSON
class YouTubeVideosContentDetailsContentRating {
	/**
	 * The video's Australian Classification Board (ACB) or Australian Communications and Media Authority (ACMA) rating. ACMA ratings are used to classify children's television programming.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>acbC</code> – Programs that have been given a <code>C</code> classification by the Australian Communications and Media Authority. These programs are intended for children (other than preschool children) who are younger than 14 years of age.</li> 
	  <li><code>acbE</code> – E</li> 
	  <li><code>acbG</code> – G</li> 
	  <li><code>acbM</code> – M</li> 
	  <li><code>acbMa15plus</code> – MA15+</li> 
	  <li><code>acbP</code> – Programs that have been given a <code>P</code> classification by the Australian Communications and Media Authority. These programs are intended for preschool children.</li> 
	  <li><code>acbPg</code> – PG</li> 
	  <li><code>acbR18plus</code> – R18+</li> 
	  <li><code>acbUnrated</code></li> 
	 </ul>
	 */
	String acbRating
	
	/**
	 * The video's rating from Italy's Autorità per le Garanzie nelle Comunicazioni (AGCOM).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>agcomT</code> – T</li> 
	  <li><code>agcomUnrated</code></li> 
	  <li><code>agcomVm14</code> – VM14</li> 
	  <li><code>agcomVm18</code> – VM18</li> 
	 </ul>
	 */
	String agcomRating
	
	/**
	 * The video's Anatel (Asociación Nacional de Televisión) rating for Chilean television.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>anatelA</code> – A</li> 
	  <li><code>anatelF</code> – F</li> 
	  <li><code>anatelI</code> – I</li> 
	  <li><code>anatelI10</code> – I-10</li> 
	  <li><code>anatelI12</code> – I-12</li> 
	  <li><code>anatelI7</code> – I-7</li> 
	  <li><code>anatelR</code> – R</li> 
	  <li><code>anatelUnrated</code></li> 
	 </ul>
	 */
	String anatelRating
	
	/**
	 * The video's British Board of Film Classification (BBFC) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>bbfc12</code> – 12</li> 
	  <li><code>bbfc12a</code> – 12A</li> 
	  <li><code>bbfc15</code> – 15</li> 
	  <li><code>bbfc18</code> – 18</li> 
	  <li><code>bbfcPg</code> – PG</li> 
	  <li><code>bbfcR18</code> – R18</li> 
	  <li><code>bbfcU</code> – U</li> 
	  <li><code>bbfcUnrated</code></li> 
	 </ul>
	 */
	String bbfcRating
	
	/**
	 * The video's rating from Thailand's Board of Film and Video Censors.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>bfvc13</code> – 13</li> 
	  <li><code>bfvc15</code> – 15</li> 
	  <li><code>bfvc18</code> – 18</li> 
	  <li><code>bfvc20</code> – 20</li> 
	  <li><code>bfvcB</code> – B</li> 
	  <li><code>bfvcE</code> – E</li> 
	  <li><code>bfvcG</code> – G</li> 
	  <li><code>bfvcUnrated</code></li> 
	 </ul>
	 */
	String bfvcRating
	
	/**
	 * The video's rating from the Austrian Board of Media Classification (Bundesministeriums für Unterricht, Kunst und Kultur).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>bmukk10</code> – 10+</li> 
	  <li><code>bmukk12</code> – 12+</li> 
	  <li><code>bmukk14</code> – 14+</li> 
	  <li><code>bmukk16</code> – 16+</li> 
	  <li><code>bmukk6</code> – 6+</li> 
	  <li><code>bmukk8</code> – 8+</li> 
	  <li><code>bmukkAa</code> – Unrestricted</li> 
	  <li><code>bmukkUnrated</code></li> 
	 </ul>
	 */
	String bmukkRating
	
	/**
	 * Rating system for Canadian TV - Canadian TV Classification System The video's rating from the Canadian Radio-Television and Telecommunications Commission (CRTC) for Canadian English-language broadcasts. For more information, see the <a href="http://www.cbsc.ca/english/agvot/englishsystem.php">Canadian Broadcast Standards Council</a> website.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>catv14plus</code> – 14+</li> 
	  <li><code>catv18plus</code> – 18+</li> 
	  <li><code>catvC</code> – C</li> 
	  <li><code>catvC8</code> – C8</li> 
	  <li><code>catvG</code> – G</li> 
	  <li><code>catvPg</code> – PG</li> 
	  <li><code>catvUnrated</code></li> 
	 </ul>
	 */
	String catvRating
	
	/**
	 * The video's rating from the Canadian Radio-Television and Telecommunications Commission (CRTC) for Canadian French-language broadcasts. For more information, see the <a href="http://www.cbsc.ca/english/agvot/frenchsystem.php">Canadian Broadcast Standards Council</a> website.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>catvfr13plus</code> – 13+</li> 
	  <li><code>catvfr16plus</code> – 16+</li> 
	  <li><code>catvfr18plus</code> – 18+</li> 
	  <li><code>catvfr8plus</code> – 8+</li> 
	  <li><code>catvfrG</code> – G</li> 
	  <li><code>catvfrUnrated</code></li> 
	 </ul>
	 */
	String catvfrRating
	
	/**
	 * The video's Central Board of Film Certification (CBFC - India) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>cbfcA</code> – A</li> 
	  <li><code>cbfcS</code> – S</li> 
	  <li><code>cbfcU</code> – U</li> 
	  <li><code>cbfcUA</code> – U/A</li> 
	  <li><code>cbfcUnrated</code></li> 
	 </ul>
	 */
	String cbfcRating
	
	/**
	 * The video's Consejo de Calificación Cinematográfica (Chile) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>ccc14</code> – 14+</li> 
	  <li><code>ccc18</code> – 18+</li> 
	  <li><code>ccc18s</code> – 18+ - contenido pornográfico</li> 
	  <li><code>ccc18v</code> – 18+ - contenido excesivamente violento</li> 
	  <li><code>ccc6</code> – 6+ - Inconveniente para menores de 7 años</li> 
	  <li><code>cccTe</code> – Todo espectador</li> 
	  <li><code>cccUnrated</code></li> 
	 </ul>
	 */
	String cccRating
	
	/**
	 * The video's rating from Portugal's Comissão de Classificação de Espect´culos.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>cceM12</code> – 12</li> 
	  <li><code>cceM16</code> – 16</li> 
	  <li><code>cceM18</code> – 18</li> 
	  <li><code>cceM4</code> – 4</li> 
	  <li><code>cceM6</code> – 6</li> 
	  <li><code>cceUnrated</code></li> 
	 </ul>
	 */
	String cceRating
	
	/**
	 * The video's rating in Switzerland.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>chfilm0</code> – 0</li> 
	  <li><code>chfilm12</code> – 12</li> 
	  <li><code>chfilm16</code> – 16</li> 
	  <li><code>chfilm18</code> – 18</li> 
	  <li><code>chfilm6</code> – 6</li> 
	  <li><code>chfilmUnrated</code></li> 
	 </ul>
	 */
	String chfilmRating
	
	/**
	 * The video's Canadian Home Video Rating System (CHVRS) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>chvrs14a</code> – 14A</li> 
	  <li><code>chvrs18a</code> – 18A</li> 
	  <li><code>chvrsE</code> – E</li> 
	  <li><code>chvrsG</code> – G</li> 
	  <li><code>chvrsPg</code> – PG</li> 
	  <li><code>chvrsR</code> – R</li> 
	  <li><code>chvrsUnrated</code></li> 
	 </ul>
	 */
	String chvrsRating
	
	/**
	 * The video's rating from the Commission de Contrôle des Films (Belgium).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>cicfE</code> – E</li> 
	  <li><code>cicfKntEna</code> – KNT/ENA</li> 
	  <li><code>cicfKtEa</code> – KT/EA</li> 
	  <li><code>cicfUnrated</code></li> 
	 </ul>
	 */
	String cicfRating
	
	/**
	 * The video's rating from Romania's CONSILIUL NATIONAL AL AUDIOVIZUALULUI (CNA).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>cna12</code> – 12</li> 
	  <li><code>cna15</code> – 15</li> 
	  <li><code>cna18</code> – 18</li> 
	  <li><code>cna18plus</code> – 18+</li> 
	  <li><code>cnaAp</code> – AP</li> 
	  <li><code>cnaUnrated</code></li> 
	 </ul>
	 */
	String cnaRating
	
	/**
	 * The video's rating from France's Conseil supérieur de l?audiovisuel, which rates broadcast content.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>csa10</code> – 10</li> 
	  <li><code>csa12</code> – 12</li> 
	  <li><code>csa16</code> – 16</li> 
	  <li><code>csa18</code> – 18</li> 
	  <li><code>csaInterdiction</code> – Interdiction</li> 
	  <li><code>csaUnrated</code></li> 
	 </ul>
	 */
	String csaRating
	
	/**
	 * The video's rating from Luxembourg's Commission de surveillance de la classification des films (CSCF).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>cscf12</code> – 12</li> 
	  <li><code>cscf16</code> – 16</li> 
	  <li><code>cscf18</code> – 18</li> 
	  <li><code>cscf6</code> – 6</li> 
	  <li><code>cscfA</code> – A</li> 
	  <li><code>cscfUnrated</code></li> 
	 </ul>
	 */
	String cscfRating
	
	/**
	 * The video's rating in the Czech Republic.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>czfilm12</code> – 12</li> 
	  <li><code>czfilm14</code> – 14</li> 
	  <li><code>czfilm18</code> – 18</li> 
	  <li><code>czfilmU</code> – U</li> 
	  <li><code>czfilmUnrated</code></li> 
	 </ul>
	 */
	String czfilmRating
	
	/**
	 * The video's Departamento de Justiça, Classificação, Qualificação e Títulos (DJCQT - Brazil) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>djctq10</code> – 10</li> 
	  <li><code>djctq12</code> – 12</li> 
	  <li><code>djctq14</code> – 14</li> 
	  <li><code>djctq16</code> – 16</li> 
	  <li><code>djctq18</code> – 18</li> 
	  <li><code>djctqL</code> – L</li> 
	  <li><code>djctqUnrated</code></li> 
	 </ul>
	 */
	String djctqRating
	
	/**
	 * Reasons that explain why the video received its DJCQT (Brazil) rating.
	 */
	List<String> djctqRatingReasons
	
	/**
	 * The video's rating in Estonia.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>eefilmK12</code> – K-12</li> 
	  <li><code>eefilmK14</code> – K-14</li> 
	  <li><code>eefilmK16</code> – K-16</li> 
	  <li><code>eefilmK6</code> – K-6</li> 
	  <li><code>eefilmL</code> – L</li> 
	  <li><code>eefilmMs12</code> – MS-12</li> 
	  <li><code>eefilmMs6</code> – MS-6</li> 
	  <li><code>eefilmPere</code> – Pere</li> 
	  <li><code>eefilmUnrated</code></li> 
	 </ul>
	 */
	String eefilmRating
	
	/**
	 * The video's rating in Egypt.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>egfilm18</code> – 18</li> 
	  <li><code>egfilmBn</code> – BN</li> 
	  <li><code>egfilmGn</code> – GN</li> 
	  <li><code>egfilmUnrated</code></li> 
	 </ul>
	 */
	String egfilmRating
	
	/**
	 * The video's Eirin (映倫) rating. Eirin is the Japanese rating system.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>eirinG</code> – G</li> 
	  <li><code>eirinPg12</code> – PG-12</li> 
	  <li><code>eirinR15plus</code> – R15+</li> 
	  <li><code>eirinR18plus</code> – R18+</li> 
	  <li><code>eirinUnrated</code></li> 
	 </ul>
	 */
	String eirinRating
	
	/**
	 * The video's rating from Malaysia's Film Censorship Board.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>fcbm18</code> – 18</li> 
	  <li><code>fcbm18pa</code> – 18PA</li> 
	  <li><code>fcbm18pl</code> – 18PL</li> 
	  <li><code>fcbm18sg</code> – 18SG</li> 
	  <li><code>fcbm18sx</code> – 18SX</li> 
	  <li><code>fcbmP13</code> – P13</li> 
	  <li><code>fcbmU</code> – U</li> 
	  <li><code>fcbmUnrated</code></li> 
	 </ul>
	 */
	String fcbmRating
	
	/**
	 * The video's rating from Hong Kong's Office for Film, Newspaper and Article Administration.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>fcoI</code> – I</li> 
	  <li><code>fcoIia</code> – IIA</li> 
	  <li><code>fcoIib</code> – IIB</li> 
	  <li><code>fcoIii</code> – III</li> 
	  <li><code>fcoUnrated</code></li> 
	 </ul>
	 */
	String fcoRating
	
	/**
	 * The video's Centre national du cinéma et de l'image animé (French Ministry of Culture) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>fmoc10</code> – 10</li> 
	  <li><code>fmoc12</code> – 12</li> 
	  <li><code>fmoc16</code> – 16</li> 
	  <li><code>fmoc18</code> – 18</li> 
	  <li><code>fmocE</code> – E</li> 
	  <li><code>fmocU</code> – U</li> 
	  <li><code>fmocUnrated</code></li> 
	 </ul>
	 */
	String fmocRating
	
	/**
	 * The video's rating from South Africa's Film and Publication Board.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>fpb1012Pg</code> – 10-12PG</li> 
	  <li><code>fpb13</code> – 13</li> 
	  <li><code>fpb16</code> – 16</li> 
	  <li><code>fpb18</code> – 18</li> 
	  <li><code>fpb79Pg</code> – 7-9PG</li> 
	  <li><code>fpbA</code> – A</li> 
	  <li><code>fpbPg</code> – PG</li> 
	  <li><code>fpbUnrated</code></li> 
	  <li><code>fpbX18</code> – X18</li> 
	  <li><code>fpbXx</code> – XX</li> 
	 </ul>
	 */
	String fpbRating
	
	/**
	 * The video's Freiwillige Selbstkontrolle der Filmwirtschaft (FSK - Germany) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>fsk0</code> – FSK 0</li> 
	  <li><code>fsk12</code> – FSK 12</li> 
	  <li><code>fsk16</code> – FSK 16</li> 
	  <li><code>fsk18</code> – FSK 18</li> 
	  <li><code>fsk6</code> – FSK 6</li> 
	  <li><code>fskUnrated</code></li> 
	 </ul>
	 */
	String fskRating
	
	/**
	 * The video's rating in Greece.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>grfilmE</code> – E</li> 
	  <li><code>grfilmK</code> – K</li> 
	  <li><code>grfilmK13</code> – K-13</li> 
	  <li><code>grfilmK17</code> – K-17</li> 
	  <li><code>grfilmUnrated</code></li> 
	 </ul>
	 */
	String grfilmRating
	
	/**
	 * The video's Instituto de la Cinematografía y de las Artes Audiovisuales (ICAA - Spain) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>icaa12</code> – 12</li> 
	  <li><code>icaa13</code> – 13</li> 
	  <li><code>icaa16</code> – 16</li> 
	  <li><code>icaa18</code> – 18</li> 
	  <li><code>icaa7</code> – 7</li> 
	  <li><code>icaaApta</code> – APTA</li> 
	  <li><code>icaaUnrated</code></li> 
	  <li><code>icaaX</code> – X</li> 
	 </ul>
	 */
	String icaaRating
	
	/**
	 * The video's Irish Film Classification Office (IFCO - Ireland) rating. See the <a href="http://www.ifco.ie/website/ifco/ifcoweb.nsf/web/classcatintro">IFCO</a> website for more information.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>ifco12</code> – 12</li> 
	  <li><code>ifco15</code> – 15</li> 
	  <li><code>ifco18</code> – 18</li> 
	  <li><code>ifcoG</code> – G</li> 
	  <li><code>ifcoPg</code> – PG</li> 
	  <li><code>ifcoUnrated</code></li> 
	 </ul>
	 */
	String ifcoRating
	
	/**
	 * The video's rating in Israel.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>ilfilm12</code> – 12</li> 
	  <li><code>ilfilm16</code> – 16</li> 
	  <li><code>ilfilm18</code> – 18</li> 
	  <li><code>ilfilmAa</code> – AA</li> 
	  <li><code>ilfilmUnrated</code></li> 
	 </ul>
	 */
	String ilfilmRating
	
	/**
	 * The video's INCAA (Instituto Nacional de Cine y Artes Audiovisuales - Argentina) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>incaaAtp</code> – ATP (Apta para todo publico)</li> 
	  <li><code>incaaC</code> – X (Solo apta para mayores de 18 años, de exhibición condicionada)</li> 
	  <li><code>incaaSam13</code> – 13 (Solo apta para mayores de 13 años)</li> 
	  <li><code>incaaSam16</code> – 16 (Solo apta para mayores de 16 años)</li> 
	  <li><code>incaaSam18</code> – 18 (Solo apta para mayores de 18 años)</li> 
	  <li><code>incaaUnrated</code></li> 
	 </ul>
	 */
	String incaaRating
	
	/**
	 * The video's rating from the Kenya Film Classification Board.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>kfcb16plus</code> – 16</li> 
	  <li><code>kfcbG</code> – GE</li> 
	  <li><code>kfcbPg</code> – PG</li> 
	  <li><code>kfcbR</code> – 18</li> 
	  <li><code>kfcbUnrated</code></li> 
	 </ul>
	 */
	String kfcbRating
	
	/**
	 * voor de Classificatie van Audiovisuele Media (Netherlands).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>kijkwijzer12</code> – 12</li> 
	  <li><code>kijkwijzer16</code> – 16</li> 
	  <li><code>kijkwijzer6</code> – 6</li> 
	  <li><code>kijkwijzer9</code> – 9</li> 
	  <li><code>kijkwijzerAl</code> – AL</li> 
	  <li><code>kijkwijzerUnrated</code></li> 
	 </ul>
	 */
	String kijkwijzerRating
	
	/**
	 * The video's Korea Media Rating Board (영상물등급위원회) rating. The KMRB rates videos in South Korea.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>kmrb12plus</code> – 12세 이상 관람가</li> 
	  <li><code>kmrb15plus</code> – 15세 이상 관람가</li> 
	  <li><code>kmrbAll</code> – 전체관람가</li> 
	  <li><code>kmrbR</code> – 청소년 관람불가</li> 
	  <li><code>kmrbTeenr</code></li> 
	  <li><code>kmrbUnrated</code></li> 
	 </ul>
	 */
	String kmrbRating
	
	/**
	 * The video's rating from Indonesia's Lembaga Sensor Film.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>lsfA</code> – A</li> 
	  <li><code>lsfBo</code> – BO</li> 
	  <li><code>lsfD</code> – D</li> 
	  <li><code>lsfR</code> – R</li> 
	  <li><code>lsfSu</code> – SU</li> 
	  <li><code>lsfUnrated</code></li> 
	 </ul>
	 */
	String lsfRating
	
	/**
	 * The video's rating from Malta's Film Age-Classification Board.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mccaa12</code> – 12</li> 
	  <li><code>mccaa12a</code> – 12A</li> 
	  <li><code>mccaa14</code> – 14 - this rating was removed from the new classification structure introduced in 2013.</li> 
	  <li><code>mccaa15</code> – 15</li> 
	  <li><code>mccaa16</code> – 16 - this rating was removed from the new classification structure introduced in 2013.</li> 
	  <li><code>mccaa18</code> – 18</li> 
	  <li><code>mccaaPg</code> – PG</li> 
	  <li><code>mccaaU</code> – U</li> 
	  <li><code>mccaaUnrated</code></li> 
	 </ul>
	 */
	String mccaaRating
	
	/**
	 * The video's rating from the Danish Film Institute's (Det Danske Filminstitut) Media Council for Children and Young People.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mccyp11</code> – 11</li> 
	  <li><code>mccyp15</code> – 15</li> 
	  <li><code>mccyp7</code> – 7</li> 
	  <li><code>mccypA</code> – A</li> 
	  <li><code>mccypUnrated</code></li> 
	 </ul>
	 */
	String mccypRating
	
	/**
	 * The video's rating from Singapore's Media Development Authority (MDA) and, specifically, it's Board of Film Censors (BFC).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mdaG</code> – G</li> 
	  <li><code>mdaM18</code> – M18</li> 
	  <li><code>mdaNc16</code> – NC16</li> 
	  <li><code>mdaPg</code> – PG</li> 
	  <li><code>mdaPg13</code> – PG13</li> 
	  <li><code>mdaR21</code> – R21</li> 
	  <li><code>mdaUnrated</code></li> 
	 </ul>
	 */
	String mdaRating
	
	/**
	 * The video's rating from Medietilsynet, the Norwegian Media Authority.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>medietilsynet11</code> – 11</li> 
	  <li><code>medietilsynet15</code> – 15</li> 
	  <li><code>medietilsynet18</code> – 18</li> 
	  <li><code>medietilsynet7</code> – 7</li> 
	  <li><code>medietilsynetA</code> – A</li> 
	  <li><code>medietilsynetUnrated</code></li> 
	 </ul>
	 */
	String medietilsynetRating
	
	/**
	 * The video's rating from Finland's Kansallinen Audiovisuaalinen Instituutti (National Audiovisual Institute).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>meku12</code> – 12</li> 
	  <li><code>meku16</code> – 16</li> 
	  <li><code>meku18</code> – 18</li> 
	  <li><code>meku7</code> – 7</li> 
	  <li><code>mekuS</code> – S</li> 
	  <li><code>mekuUnrated</code></li> 
	 </ul>
	 */
	String mekuRating
	
	/**
	 * The video's rating from the Ministero dei Beni e delle Attività Culturali e del Turismo (Italy).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mibacT</code></li> 
	  <li><code>mibacUnrated</code></li> 
	  <li><code>mibacVap</code></li> 
	  <li><code>mibacVm12</code></li> 
	  <li><code>mibacVm14</code></li> 
	  <li><code>mibacVm18</code></li> 
	 </ul>
	 */
	String mibacRating
	
	/**
	 * The video's Ministerio de Cultura (Colombia) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>moc12</code> – 12</li> 
	  <li><code>moc15</code> – 15</li> 
	  <li><code>moc18</code> – 18</li> 
	  <li><code>moc7</code> – 7</li> 
	  <li><code>mocBanned</code> – Banned</li> 
	  <li><code>mocE</code> – E</li> 
	  <li><code>mocT</code> – T</li> 
	  <li><code>mocUnrated</code></li> 
	  <li><code>mocX</code> – X</li> 
	 </ul>
	 */
	String mocRating
	
	/**
	 * The video's rating from Taiwan's Ministry of Culture (文化部).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>moctwG</code> – G</li> 
	  <li><code>moctwP</code> – P</li> 
	  <li><code>moctwPg</code> – PG</li> 
	  <li><code>moctwR</code> – R</li> 
	  <li><code>moctwUnrated</code></li> 
	 </ul>
	 */
	String moctwRating
	
	/**
	 * The video's Motion Picture Association of America (MPAA) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mpaaG</code> – G</li> 
	  <li><code>mpaaNc17</code> – NC-17</li> 
	  <li><code>mpaaPg</code> – PG</li> 
	  <li><code>mpaaPg13</code> – PG-13</li> 
	  <li><code>mpaaR</code> – R</li> 
	  <li><code>mpaaUnrated</code></li> 
	 </ul>
	 */
	String mpaaRating
	
	/**
	 * The video's rating from the Movie and Television Review and Classification Board (Philippines).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>mtrcbG</code> – G</li> 
	  <li><code>mtrcbPg</code> – PG</li> 
	  <li><code>mtrcbR13</code> – R-13</li> 
	  <li><code>mtrcbR16</code> – R-16</li> 
	  <li><code>mtrcbR18</code> – R-18</li> 
	  <li><code>mtrcbUnrated</code></li> 
	  <li><code>mtrcbX</code> – X</li> 
	 </ul>
	 */
	String mtrcbRating
	
	/**
	 * The video's rating from the Maldives National Bureau of Classification.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>nbc12plus</code> – 12+</li> 
	  <li><code>nbc15plus</code> – 15+</li> 
	  <li><code>nbc18plus</code> – 18+</li> 
	  <li><code>nbc18plusr</code> – 18+R</li> 
	  <li><code>nbcG</code> – G</li> 
	  <li><code>nbcPg</code> – PG</li> 
	  <li><code>nbcPu</code> – PU</li> 
	  <li><code>nbcUnrated</code></li> 
	 </ul>
	 */
	String nbcRating
	
	/**
	 * The video's rating from the <a href="http://http://www.nfc.bg/">Bulgarian National Film Center</a>.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>nfrcA</code> – A</li> 
	  <li><code>nfrcB</code> – B</li> 
	  <li><code>nfrcC</code> – C</li> 
	  <li><code>nfrcD</code> – D</li> 
	  <li><code>nfrcUnrated</code></li> 
	  <li><code>nfrcX</code> – X</li> 
	 </ul>
	 */
	String nfrcRating
	
	/**
	 * The video's rating from Nigeria's National Film and Video Censors Board.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>nfvcb12</code> – 12</li> 
	  <li><code>nfvcb12a</code> – 12A</li> 
	  <li><code>nfvcb15</code> – 15</li> 
	  <li><code>nfvcb18</code> – 18</li> 
	  <li><code>nfvcbG</code> – G</li> 
	  <li><code>nfvcbPg</code> – PG</li> 
	  <li><code>nfvcbRe</code> – RE</li> 
	  <li><code>nfvcbUnrated</code></li> 
	 </ul>
	 */
	String nfvcbRating
	
	/**
	 * The video's rating from the Nacionãlais Kino centrs (National Film Centre of Latvia).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>nkclv12plus</code> – 12+</li> 
	  <li><code>nkclv18plus</code> – 18+</li> 
	  <li><code>nkclv7plus</code> – 7+</li> 
	  <li><code>nkclvU</code> – U</li> 
	  <li><code>nkclvUnrated</code></li> 
	 </ul>
	 */
	String nkclvRating
	
	/**
	 * The video's Office of Film and Literature Classification (OFLC - New Zealand) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>oflcG</code> – G</li> 
	  <li><code>oflcM</code> – M</li> 
	  <li><code>oflcPg</code> – PG</li> 
	  <li><code>oflcR13</code> – R13</li> 
	  <li><code>oflcR15</code> – R15</li> 
	  <li><code>oflcR16</code> – R16</li> 
	  <li><code>oflcR18</code> – R18</li> 
	  <li><code>oflcRp13</code> – RP13</li> 
	  <li><code>oflcRp16</code> – RP16</li> 
	  <li><code>oflcUnrated</code></li> 
	 </ul>
	 */
	String oflcRating
	
	/**
	 * The video's rating in Peru.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>pefilm14</code> – 14</li> 
	  <li><code>pefilm18</code> – 18</li> 
	  <li><code>pefilmPg</code> – PG</li> 
	  <li><code>pefilmPt</code> – PT</li> 
	  <li><code>pefilmUnrated</code></li> 
	 </ul>
	 */
	String pefilmRating
	
	/**
	 * The video's rating in Venezuela.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>resorteviolenciaA</code> – A</li> 
	  <li><code>resorteviolenciaB</code> – B</li> 
	  <li><code>resorteviolenciaC</code> – C</li> 
	  <li><code>resorteviolenciaD</code> – D</li> 
	  <li><code>resorteviolenciaE</code> – E</li> 
	  <li><code>resorteviolenciaUnrated</code></li> 
	 </ul>
	 */
	String resorteviolenciaRating
	
	/**
	 * The video's General Directorate of Radio, Television and Cinematography (Mexico) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>rtcA</code> – A</li> 
	  <li><code>rtcAa</code> – AA</li> 
	  <li><code>rtcB</code> – B</li> 
	  <li><code>rtcB15</code> – B15</li> 
	  <li><code>rtcC</code> – C</li> 
	  <li><code>rtcD</code> – D</li> 
	  <li><code>rtcUnrated</code></li> 
	 </ul>
	 */
	String rtcRating
	
	/**
	 * The video's rating from Ireland's Raidió Teilifís Éireann.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>rteCh</code> – CH</li> 
	  <li><code>rteGa</code> – GA</li> 
	  <li><code>rteMa</code> – MA</li> 
	  <li><code>rtePs</code> – PS</li> 
	  <li><code>rteUnrated</code></li> 
	 </ul>
	 */
	String rteRating
	
	/**
	 * The video's National Film Registry of the Russian Federation (MKRF - Russia) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>russia0</code> – 0+</li> 
	  <li><code>russia12</code> – 12+</li> 
	  <li><code>russia16</code> – 16+</li> 
	  <li><code>russia18</code> – 18+</li> 
	  <li><code>russia6</code> – 6+</li> 
	  <li><code>russiaUnrated</code></li> 
	 </ul>
	 */
	String russiaRating
	
	/**
	 * The video's rating in Slovakia.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>skfilmG</code> – G</li> 
	  <li><code>skfilmP2</code> – P2</li> 
	  <li><code>skfilmP5</code> – P5</li> 
	  <li><code>skfilmP8</code> – P8</li> 
	  <li><code>skfilmUnrated</code></li> 
	 </ul>
	 */
	String skfilmRating
	
	/**
	 * The video's rating in Iceland.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>smais12</code> – 12</li> 
	  <li><code>smais14</code> – 14</li> 
	  <li><code>smais16</code> – 16</li> 
	  <li><code>smais18</code> – 18</li> 
	  <li><code>smais7</code> – 7</li> 
	  <li><code>smaisL</code> – L</li> 
	  <li><code>smaisUnrated</code></li> 
	 </ul>
	 */
	String smaisRating
	
	/**
	 * The video's rating from Statens medieråd (Sweden's National Media Council).<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>smsa11</code> – 11</li> 
	  <li><code>smsa15</code> – 15</li> 
	  <li><code>smsa7</code> – 7</li> 
	  <li><code>smsaA</code> – All ages</li> 
	  <li><code>smsaUnrated</code></li> 
	 </ul>
	 */
	String smsaRating
	
	/**
	 * The video's TV Parental Guidelines (TVPG) rating.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>pg14</code> – TV-14</li> 
	  <li><code>tvpgG</code> – TV-G</li> 
	  <li><code>tvpgMa</code> – TV-MA</li> 
	  <li><code>tvpgPg</code> – TV-PG</li> 
	  <li><code>tvpgUnrated</code></li> 
	  <li><code>tvpgY</code> – TV-Y</li> 
	  <li><code>tvpgY7</code> – TV-Y7</li> 
	  <li><code>tvpgY7Fv</code> – TV-Y7-FV</li> 
	 </ul>
	 */
	String tvpgRating
	
	/**
	 * A rating that YouTube uses to identify age-restricted content.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>ytAgeRestricted</code></li> 
	 </ul>
	 */
	String ytRating
	
}

@JSON
class YouTubeVideosStatus {
	/**
	 * The status of the uploaded video.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>deleted</code></li> 
	  <li><code>failed</code></li> 
	  <li><code>processed</code></li> 
	  <li><code>rejected</code></li> 
	  <li><code>uploaded</code></li> 
	 </ul>
	 */
	String uploadStatus
	
	/**
	 * This value explains why a video failed to upload. This property is only present if the <code>uploadStatus</code> property indicates that the upload failed.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>codec</code></li> 
	  <li><code>conversion</code></li> 
	  <li><code>emptyFile</code></li> 
	  <li><code>invalidFile</code></li> 
	  <li><code>tooSmall</code></li> 
	  <li><code>uploadAborted</code></li> 
	 </ul>
	 */
	String failureReason
	
	/**
	 * This value explains why YouTube rejected an uploaded video. This property is only present if the <code>uploadStatus</code> property indicates that the upload was rejected.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>claim</code></li> 
	  <li><code>copyright</code></li> 
	  <li><code>duplicate</code></li> 
	  <li><code>inappropriate</code></li> 
	  <li><code>length</code></li> 
	  <li><code>termsOfUse</code></li> 
	  <li><code>trademark</code></li> 
	  <li><code>uploaderAccountClosed</code></li> 
	  <li><code>uploaderAccountSuspended</code></li> 
	 </ul>
	 */
	String rejectionReason
	
	/**
	 * The video's privacy status.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>private</code></li> 
	  <li><code>public</code></li> 
	  <li><code>unlisted</code></li> 
	 </ul>
	 */
	String privacyStatus
	
	/**
	 * The date and time when the video is scheduled to publish. It can be set only if the privacy status of the video is private. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date publishAt
	
	/**
	 * The video's license.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>creativeCommon</code></li> 
	  <li><code>youtube</code></li> 
	 </ul>
	 */
	String license
	
	/**
	 * This value indicates whether the video can be embedded on another website.
	 */
	boolean embeddable
	
	/**
	 * This value indicates whether the extended video statistics on the video's watch page are publicly viewable. By default, those statistics are viewable, and statistics like a video's viewcount and ratings will still be publicly visible even if this property's value is set to <code>false</code>.
	 */
	boolean publicStatsViewable
	
}

@JSON
class YouTubeVideosStatistics {
	/**
	 * The number of times the video has been viewed.
	 */
	long viewCount
	
	/**
	 * The number of users who have indicated that they liked the video.
	 */
	long likeCount
	
	/**
	 * The number of users who have indicated that they disliked the video.
	 */
	long dislikeCount
	
	/**
	 * <b>Note:</b> This property has been deprecated. The deprecation is effective as of August 28, 2015. The property's value is now always set to <code>0</code>.
	 */
	long favoriteCount
	
	/**
	 * The number of comments for the video.
	 */
	long commentCount
	
}

@JSON
class YouTubeVideosPlayer {
	/**
	 * An <code>&lt;iframe&gt;</code> tag that embeds a player that will play the video.
	 */
	String embedHtml
	
}

@JSON
class YouTubeVideosTopicDetails {
	/**
	 * A list of Freebase topic IDs that are centrally associated with the video. These are topics that are centrally featured in the video, and it can be said that the video is mainly about each of these. You can retrieve information about each topic using the <a href="http://wiki.freebase.com/wiki/Topic_API">Freebase Topic API</a>.
	 */
	List<String> topicIds
	
	/**
	 * Similar to topic_id, except that these topics are merely relevant to the video. These are topics that may be mentioned in, or appear in the video. You can retrieve information about each topic using <a href="http://wiki.freebase.com/wiki/Topic_API">Freebase Topic API</a>.
	 */
	List<String> relevantTopicIds
	
}

@JSON
class YouTubeVideosRecordingDetails {
	/**
	 * The text description of the location where the video was recorded.
	 */
	String locationDescription
	
	/**
	 * The geolocation information associated with the video.
	 */
	YouTubeVideosRecordingDetailsLocation location
	
	/**
	 * The date and time when the video was recorded. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sssZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date recordingDate
	
}

@JSON
class YouTubeVideosRecordingDetailsLocation {
	/**
	 * Latitude in degrees.
	 */
	double latitude
	
	/**
	 * Longitude in degrees.
	 */
	double longitude
	
	/**
	 * Altitude above the reference ellipsoid, in meters.
	 */
	double altitude
	
}

@JSON
class YouTubeVideosFileDetails {
	/**
	 * The uploaded file's name. This field is present whether a video file or another type of file was uploaded.
	 */
	String fileName
	
	/**
	 * The uploaded file's size in bytes. This field is present whether a video file or another type of file was uploaded.
	 */
	long fileSize
	
	/**
	 * The uploaded file's type as detected by YouTube's video processing engine. Currently, YouTube only processes video files, but this field is present whether a video file or another type of file was uploaded.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>archive</code> – The file is an archive file, such as a .zip archive.</li> 
	  <li><code>audio</code> – The file is a known audio file type, such as an .mp3 file.</li> 
	  <li><code>document</code> – The file is a document or text file, such as a MS Word document.</li> 
	  <li><code>image</code> – The file is an image file, such as a .jpeg image.</li> 
	  <li><code>other</code> – The file is another non-video file type.</li> 
	  <li><code>project</code> – The file is a video project file, such as a Microsoft Windows Movie Maker project, that does not contain actual video data.</li> 
	  <li><code>video</code> – The file is a known video file type, such as an .mp4 file.</li> 
	 </ul>
	 */
	String fileType
	
	/**
	 * The uploaded video file's container format.
	 */
	String container
	
	/**
	 * A list of video streams contained in the uploaded video file. Each item in the list contains detailed metadata about a video stream.
	 */
	List<YouTubeVideosFileDetailsVideoStreams> videoStreams
	
	/**
	 * A list of audio streams contained in the uploaded video file. Each item in the list contains detailed metadata about an audio stream.
	 */
	List<YouTubeVideosFileDetailsAudioStreams> audioStreams
	
	/**
	 * The length of the uploaded video in milliseconds.
	 */
	long durationMs
	
	/**
	 * The uploaded video file's combined (video and audio) bitrate in bits per second.
	 */
	long bitrateBps
	
	/**
	 * Geographic coordinates that identify the place where the uploaded video was recorded. Coordinates are defined using WGS 84.
	 */
	YouTubeVideosFileDetailsRecordingLocation recordingLocation
	
	/**
	 * The date and time when the uploaded video file was created. The value is specified in <a href="http://www.w3.org/TR/NOTE-datetime">ISO 8601</a> format. Currently, the following ISO 8601 formats are supported: 
	 <ul> 
	  <li>Date only: <code>YYYY-MM-DD</code></li> 
	  <li>Naive time: <code>YYYY-MM-DDTHH:MM:SS</code></li> 
	  <li>Time with timezone: <code>YYYY-MM-DDTHH:MM:SS+HH:MM</code></li> 
	 </ul>
	 */
	String creationTime
	
}

@JSON
class YouTubeVideosFileDetailsVideoStreams {
	/**
	 * The encoded video content's width in pixels. You can calculate the video's encoding aspect ratio as <code>width_pixels</code>&nbsp;/&nbsp;<code>height_pixels</code>.
	 */
	int widthPixels
	
	/**
	 * The encoded video content's height in pixels.
	 */
	int heightPixels
	
	/**
	 * The video stream's frame rate, in frames per second.
	 */
	double frameRateFps
	
	/**
	 * The video content's display aspect ratio, which specifies the aspect ratio in which the video should be displayed.
	 */
	double aspectRatio
	
	/**
	 * The video codec that the stream uses.
	 */
	String codec
	
	/**
	 * The video stream's bitrate, in bits per second.
	 */
	long bitrateBps
	
	/**
	 * The amount that YouTube needs to rotate the original source content to properly display the video.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>clockwise</code> – The video needs to be rotated 90 degrees clockwise.</li> 
	  <li><code>counterClockwise</code> – The video needs to be rotated 90 degrees counter-clockwise.</li> 
	  <li><code>none</code> – The video does not need to be rotated.</li> 
	  <li><code>other</code> – The video needs to be rotated in some other, non-trivial way.</li> 
	  <li><code>upsideDown</code> – The video needs to be rotated upside down.</li> 
	 </ul>
	 */
	String rotation
	
	/**
	 * A value that uniquely identifies a video vendor. Typically, the value is a four-letter vendor code.
	 */
	String vendor
	
}

@JSON
class YouTubeVideosFileDetailsAudioStreams {
	/**
	 * The number of audio channels that the stream contains.
	 */
	int channelCount
	
	/**
	 * The audio codec that the stream uses.
	 */
	String codec
	
	/**
	 * The audio stream's bitrate, in bits per second.
	 */
	long bitrateBps
	
	/**
	 * A value that uniquely identifies a video vendor. Typically, the value is a four-letter vendor code.
	 */
	String vendor
	
}

@JSON
class YouTubeVideosFileDetailsRecordingLocation {
	/**
	 * Latitude in degrees.
	 */
	double latitude
	
	/**
	 * Longitude in degrees.
	 */
	double longitude
	
	/**
	 * Altitude above the reference ellipsoid, in meters.
	 */
	double altitude
	
}

@JSON
class YouTubeVideosProcessingDetails {
	/**
	 * The video's processing status. This value indicates whether YouTube was able to process the video or if the video is still being processed.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>failed</code> – Video processing has failed. See ProcessingFailureReason.</li> 
	  <li><code>processing</code> – Video is currently being processed. See ProcessingProgress.</li> 
	  <li><code>succeeded</code> – Video has been successfully processed.</li> 
	  <li><code>terminated</code> – Processing information is no longer available.</li> 
	 </ul>
	 */
	String processingStatus
	
	/**
	 * The <code>processingProgress</code> object contains information about the progress YouTube has made in processing the video. The values are really only relevant if the video's processing status is <code>processing</code>.
	 */
	YouTubeVideosProcessingDetailsProcessingProgress processingProgress
	
	/**
	 * The reason that YouTube failed to process the video. This property will only have a value if the <code>processingStatus</code> property's value is <code>failed</code>.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>other</code> – Some other processing component has failed.</li> 
	  <li><code>streamingFailed</code> – Video could not be sent to streamers.</li> 
	  <li><code>transcodeFailed</code> – Content transcoding has failed.</li> 
	  <li><code>uploadFailed</code> – File delivery has failed.</li> 
	 </ul>
	 */
	String processingFailureReason
	
	/**
	 * This value indicates whether file details are available for the uploaded video. You can retrieve a video's file details by requesting the <code>fileDetails</code> part in your <code>videos.list()</code> request.
	 */
	String fileDetailsAvailability
	
	/**
	 * This value indicates whether the video processing engine has generated suggestions that might improve YouTube's ability to process the the video, warnings that explain video processing problems, or errors that cause video processing problems. You can retrieve these suggestions by requesting the <code>suggestions</code> part in your <code>videos.list()</code> request.
	 */
	String processingIssuesAvailability
	
	/**
	 * This value indicates whether keyword (tag) suggestions are available for the video. Tags can be added to a video's metadata to make it easier for other users to find the video. You can retrieve these suggestions by requesting the <code>suggestions</code> part in your <code>videos.list()</code> request.
	 */
	String tagSuggestionsAvailability
	
	/**
	 * This value indicates whether video editing suggestions, which might improve video quality or the playback experience, are available for the video. You can retrieve these suggestions by requesting the <code>suggestions</code> part in your <code>videos.list()</code> request.
	 */
	String editorSuggestionsAvailability
	
	/**
	 * This value indicates whether thumbnail images have been generated for the video.
	 */
	String thumbnailsAvailability
	
}

@JSON
class YouTubeVideosProcessingDetailsProcessingProgress {
	/**
	 * An estimate of the total number of parts that need to be processed for the video. The number may be updated with more precise estimates while YouTube processes the video.
	 */
	long partsTotal
	
	/**
	 * The number of parts of the video that YouTube has already processed. You can estimate the percentage of the video that YouTube has already processed by calculating:<br> <code>100 * parts_processed / parts_total</code><br><br> Note that since the estimated number of parts could increase without a corresponding increase in the number of parts that have already been processed, it is possible that the calculated progress could periodically decrease while YouTube processes a video.
	 */
	long partsProcessed
	
	/**
	 * An estimate of the amount of time, in millseconds, that YouTube needs to finish processing the video.
	 */
	long timeLeftMs
	
}

@JSON
class YouTubeVideosSuggestions {
	/**
	 * A list of errors that will prevent YouTube from successfully processing the uploaded video. These errors indicate that, regardless of the video's current <a href="#processingProgress.processingStatus">processing status</a>, eventually, that status will almost certainly be <code>failed</code>.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>archiveFile</code> – An archive file (e.g., a ZIP archive).</li> 
	  <li><code>audioFile</code> – File contains audio only (e.g., an MP3 file).</li> 
	  <li><code>docFile</code> – Document or text file (e.g., MS Word document).</li> 
	  <li><code>imageFile</code> – Image file (e.g., a JPEG image).</li> 
	  <li><code>notAVideoFile</code> – Other non-video file.</li> 
	  <li><code>projectFile</code> – Movie project file (e.g., Microsoft Windows Movie Maker project).</li> 
	 </ul>
	 */
	List<String> processingErrors
	
	/**
	 * A list of reasons why YouTube may have difficulty transcoding the uploaded video or that might result in an erroneous transcoding. These warnings are generated before YouTube actually processes the uploaded video file. In addition, they identify issues that do not necessarily indicate that video processing will fail but that still might cause problems such as sync issues, video artifacts, or a missing audio track.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>hasEditlist</code> – Edit lists are not currently supported.</li> 
	  <li><code>inconsistentResolution</code> – Conflicting container and stream resolutions.</li> 
	  <li><code>problematicAudioCodec</code> – Audio codec that is known to cause problems was used.</li> 
	  <li><code>problematicVideoCodec</code> – Video codec that is known to cause problems was used.</li> 
	  <li><code>unknownAudioCodec</code> – Unrecognized audio codec, transcoding is likely to fail.</li> 
	  <li><code>unknownContainer</code> – Unrecognized file format, transcoding is likely to fail.</li> 
	  <li><code>unknownVideoCodec</code> – Unrecognized video codec, transcoding is likely to fail.</li> 
	 </ul>
	 */
	List<String> processingWarnings
	
	/**
	 * A list of suggestions that may improve YouTube's ability to process the video.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>nonStreamableMov</code> – The MP4 file is not streamable, this will slow down the processing.</li> 
	  <li><code>sendBestQualityVideo</code> – Probably a better quality version of the video exists.</li> 
	 </ul>
	 */
	List<String> processingHints
	
	/**
	 * A list of keyword tags that could be added to the video's metadata to increase the likelihood that users will locate your video when searching or browsing on YouTube.
	 */
	List<YouTubeVideosSuggestionsTagSuggestions> tagSuggestions
	
	/**
	 * A list of video editing operations that might improve the video quality or playback experience of the uploaded video.<br><br>Valid values for this property are: 
	 <ul> 
	  <li><code>audioQuietAudioSwap</code> – The audio track appears silent and could be swapped with a better quality one.</li> 
	  <li><code>videoAutoLevels</code> – Picture brightness levels seem off and could be corrected.</li> 
	  <li><code>videoCrop</code> – Margins (mattes) detected around the picture could be cropped.</li> 
	  <li><code>videoStabilize</code> – The video appears shaky and could be stabilized.</li> 
	 </ul>
	 */
	List<String> editorSuggestions
	
}

@JSON
class YouTubeVideosSuggestionsTagSuggestions {
	/**
	 * The keyword tag suggested for the video.
	 */
	String tag
	
	/**
	 * A set of video categories for which the tag is relevant. You can use this information to display appropriate tag suggestions based on the video category that the video uploader associates with the video. By default, tag suggestions are relevant for all categories if there are no restricts defined for the keyword.
	 */
	List<String> categoryRestricts
	
}

@JSON
class YouTubeVideosLiveStreamingDetails {
	/**
	 * The time that the broadcast actually started. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format. This value will not be available until the broadcast begins.
	 */
	@WithConverter(YouTubeDateConverter) Date actualStartTime
	
	/**
	 * The time that the broadcast actually ended. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format. This value will not be available until the broadcast is over.
	 */
	@WithConverter(YouTubeDateConverter) Date actualEndTime
	
	/**
	 * The time that the broadcast is scheduled to begin. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format.
	 */
	@WithConverter(YouTubeDateConverter) Date scheduledStartTime
	
	/**
	 * The time that the broadcast is scheduled to end. The value is specified in <a href="//www.w3.org/TR/NOTE-datetime">ISO 8601</a> (<code>YYYY-MM-DDThh:mm:ss.sZ</code>) format. If the value is empty or the property is not present, then the broadcast is scheduled to continue indefinitely.
	 */
	@WithConverter(YouTubeDateConverter) Date scheduledEndTime
	
	/**
	 * The number of viewers currently watching the broadcast. The property and its value will be present if the broadcast has current viewers and the broadcast owner has not hidden the viewcount for the video. Note that YouTube stops tracking the number of concurrent viewers for a broadcast when the broadcast ends. So, this property would not identify the number of viewers watching an archived video of a live broadcast that already ended.
	 */
	long concurrentViewers
	
}


