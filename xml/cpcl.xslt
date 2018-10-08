<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:z="http://www.fensystems.co.uk/xmlns/cpcl"
		version="1.0">

  <!-- Output in plain text -->
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <!-- CRLF line ending -->
  <xsl:template name="crlf">
    <xsl:text>&#xd;&#xa;</xsl:text>
  </xsl:template>

  <!-- Convert element name to (uppercase) CPCL command name -->
  <xsl:template name="command">
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:value-of select="translate(local-name(),$lowercase,$uppercase)"/>
  </xsl:template>

  <!-- Root element -->
  <xsl:template match="/z:cpcl">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Print element -->
  <xsl:template match="z:print">
    <xsl:text>! </xsl:text>
    <xsl:choose>
      <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@xdpi"><xsl:value-of select="@xdpi"/></xsl:when>
      <xsl:when test="@dpi"><xsl:value-of select="@dpi"/></xsl:when>
      <xsl:otherwise><xsl:text>200</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@ydpi"><xsl:value-of select="@ydpi"/></xsl:when>
      <xsl:when test="@dpi"><xsl:value-of select="@dpi"/></xsl:when>
      <xsl:otherwise><xsl:text>200</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@qty"><xsl:value-of select="@qty"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>PRINT</xsl:text>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Utilities element -->
  <xsl:template match="z:utilities |
		       z:u">
    <xsl:text>! </xsl:text>
    <xsl:call-template name="command"/>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>PRINT</xsl:text>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Utility element -->
  <xsl:template match="z:u1">
    <xsl:text>! U1 </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Fail on unknown elements -->
  <xsl:template match="*">
    <xsl:message terminate="yes">Unrecognised element:
    <xsl:value-of select="local-name()"/>
    </xsl:message>
  </xsl:template>

  <!-- Raw data (including multiline and other miscellaneous items) -->
  <xsl:template match="z:raw |
		       z:item">
    <xsl:apply-templates/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Zero parameter commands -->
  <xsl:template match="z:form |
		       z:journal |
		       z:in-inches |
		       z:in-centimeters |
		       z:in-millimeters |
		       z:in-dots |
		       z:pace |
		       z:auto-pace |
		       z:no-pace |
		       z:rewind-off |
		       z:rewind-on |
		       z:cut |
		       z:partial-cut |
		       z:label">
    <xsl:call-template name="command"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Single parameter commands -->
  <xsl:template match="z:encoding |
		       z:count |
		       z:pattern |
		       z:rotate |
		       z:contrast |
		       z:tone |
		       z:page-width |
		       z:page-height |
		       z:pw |
		       z:wait |
		       z:pre-tension |
		       z:post-tension |
		       z:speed |
		       z:setsp |
		       z:on-feed |
		       z:prefeed |
		       z:postfeed |
		       z:country |
		       z:beep |
		       z:set-tof |
		       z:baud |
		       z:cut-at |
		       z:announce |
		       z:timeout |
		       z:lt |
		       z:setbold |
		       z:underline |
		       z:setlf">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Text commands:

       {command} {font} {size} {x} {y} {data}
  -->
  <xsl:template match="z:text |
		       z:t |
		       z:vtext |
		       z:vt |
		       z:text90 |
		       z:t90 |
		       z:text180 |
		       z:t180 |
		       z:text270 |
		       z:t270">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="font-attributes"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="*">
	<xsl:call-template name="crlf"/>
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text> </xsl:text>
	<xsl:value-of select="text()"/>
	<xsl:call-template name="crlf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="font-attributes">
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:when test="@fg"><xsl:text>FG</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>5</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:when test="@fg"><xsl:value-of select="@fg"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Scalable text commands

       {command} {name} {width} {height} {x} {y} {data}
  -->
  <xsl:template match="z:scale-text |
		       z:st |
		       z:vscale-text |
		       z:vst |
		       z:scale-to-fit |
		       z:stf |
		       z:vscale-to-fit |
		       z:vstf">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="scalable-font-attributes"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template name="scalable-font-attributes">
    <xsl:choose>
      <xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:otherwise><xsl:text>5</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Font group command:

       {command} {fg fn fs} [fn fs] ...
  -->
  <xsl:template match="z:fg">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@fg"><xsl:value-of select="@fg"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:fg/z:f">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:otherwise><xsl:text>5</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Text concatenation commands:

       {command} {x} {y}
       ( {font} {size} / <ST> {name} {width} {height} ) {offset} {data}
       ...
       <ENDCONCAT>
  -->
  <xsl:template match="z:concat |
		       z:vconcat">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>ENDCONCAT</xsl:text>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:concat/z:text |
		       z:concat/z:t |
		       z:vconcat/z:text |
		       z:vconcat/z:t">
    <xsl:call-template name="font-attributes"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:concat/z:scale-text |
		       z:concat/z:st |
		       z:vconcat/z:scale-text |
		       z:vconcat/z:st">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="scalable-font-attributes"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Multiline commands:

       {command} {height}
       {text} {font} {size} {x} {y}
       {data}
       ...
       {data}
       <ENDMULTILINE>
  -->
  <xsl:template match="z:multiline |
		       z:ml">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>END</xsl:text><xsl:call-template name="command"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Set magnification command:

       {command} {w} {h}
  -->
  <xsl:template match="z:setmag">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Barcode commands:

      {command} {type} {width} {ratio} {height} {x} {y} {data}
  -->
  <xsl:template match="z:barcode |
		       z:b |
		       z:vbarcode |
		       z:vb">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
      <xsl:otherwise><xsl:text>128</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@type = 'RSS'">
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
	  <xsl:otherwise><xsl:text>6</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@sep"><xsl:value-of select="@sep"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@segments">
	    <xsl:value-of select="@segments"/>
	  </xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@subtype"><xsl:value-of select="@subtype"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:value-of select="text()"/>
	<xsl:if test="@extra">
	  <xsl:text>|</xsl:text>
	  <xsl:value-of select="@extra"/>
	</xsl:if>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:when test="@type = 'PDF-417'">
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@width">
	  <xsl:text> XD </xsl:text>
	  <xsl:value-of select="@width"/>
	</xsl:if>
	<xsl:if test="@height">
	  <xsl:text> YD </xsl:text>
	  <xsl:value-of select="@height"/>
	</xsl:if>
	<xsl:if test="@columns">
	  <xsl:text> C </xsl:text>
	  <xsl:value-of select="@columns"/>
	</xsl:if>
	<xsl:if test="@level">
	  <xsl:text> S </xsl:text>
	  <xsl:value-of select="@level"/>
	</xsl:if>
	<xsl:call-template name="crlf"/>
	<xsl:apply-templates/>
	<xsl:text>ENDPDF</xsl:text>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:when test="@type = 'MAXICODE'">
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="crlf"/>
	<xsl:for-each select="*">
	  <xsl:call-template name="command"/>
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="text()"/>
	  <xsl:call-template name="crlf"/>
	</xsl:for-each>
	<xsl:text>ENDMAXICODE</xsl:text>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:when test="@type = 'QR'">
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@model">
	  <xsl:text> M </xsl:text>
	  <xsl:value-of select="@model"/>
	</xsl:if>
	<xsl:if test="@width or @height">
	  <xsl:text> U </xsl:text>
	  <xsl:choose>
	    <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
	    <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:call-template name="crlf"/>
	<xsl:choose>
	  <xsl:when test="@level"><xsl:value-of select="@level"/></xsl:when>
	  <xsl:otherwise><xsl:text>M</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@mask"><xsl:value-of select="@mask"/></xsl:if>
	<xsl:choose>
	  <xsl:when test="@manual"><xsl:text>M</xsl:text></xsl:when>
	  <xsl:otherwise><xsl:text>A</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="text()"/>
	<xsl:call-template name="crlf"/>
	<xsl:text>ENDQR</xsl:text>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:when test="@type = 'AZTEC'">
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@width">
	  <xsl:text> XD </xsl:text>
	  <xsl:value-of select="@width"/>
	</xsl:if>
	<xsl:if test="@level">
	  <xsl:text> EC </xsl:text>
	  <xsl:value-of select="@level"/>
	</xsl:if>
	<xsl:call-template name="crlf"/>
	<xsl:apply-templates/>
	<xsl:text>ENDAZTEC</xsl:text>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@ratio"><xsl:value-of select="@ratio"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
	  <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:value-of select="text()"/>
	<xsl:call-template name="crlf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Barcode text commands:

       {command} {font number} {font size} {offset}
       {command} OFF
  -->
  <xsl:template match="z:barcode-text |
		       z:bt">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@font or @size or @offset">
	<xsl:call-template name="font-attributes"/>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
	  <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>OFF</xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Line drawing commands:

       {command} {x0} {y0} {x1} {y1} {width}
  -->
  <xsl:template match="z:box |
		       z:line |
		       z:l |
		       z:inverse-line |
		       z:il">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x0"><xsl:value-of select="@x0"/></xsl:when>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y0"><xsl:value-of select="@y0"/></xsl:when>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x1"><xsl:value-of select="@x1"/></xsl:when>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y1"><xsl:value-of select="@y1"/></xsl:when>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Justification commands -->
  <xsl:template match="z:left |
		       z:center |
		       z:right">
    <xsl:call-template name="command"/>
    <xsl:if test="@end">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@end"/>
    </xsl:if>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Present-at commands -->
  <xsl:template match="z:present-at">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@length"><xsl:value-of select="@length"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@delay"><xsl:value-of select="@delay"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Line printer font command:

       SETLP {font name or number} {size} {unit height}
  -->
  <xsl:template match="z:setlp">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:otherwise><xsl:text>5</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Expanded graphics commands:

       {command} {width} {height} {x} {y} {data}
  -->
  <xsl:template match="z:expanded-graphics |
		       z:eg |
		       z:vexpanded-graphics |
		       z:veg |
		       z:compressed-graphics |
		       z:cg |
		       z:vcompressed-graphics |
		       z:vcg">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- On-out-of-paper command:

       {command} {action} {number of retries}
  -->
  <xsl:template match="z:on-out-of-paper">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@action"><xsl:value-of select="@action"/></xsl:when>
      <xsl:otherwise><xsl:text>PURGE</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@retries"><xsl:value-of select="@retries"/></xsl:when>
      <xsl:otherwise><xsl:text>2</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Set form feed command -->
  <xsl:template match="z:setff">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@max"><xsl:value-of select="@max"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@skip"><xsl:value-of select="@skip"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- PCX command:

       {command} {x} {y}
       {data}
  -->
  <xsl:template match="z:pcx">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@file">
	<xsl:text> !&lt;</xsl:text><xsl:value-of select="@file"/>
	<xsl:call-template name="crlf"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="crlf"/>
	<xsl:value-of select="text()"/>
	<xsl:call-template name="crlf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Use format command -->
  <xsl:template match="z:use-format |
		       z:uf">
    <xsl:text>! </xsl:text>
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@file"/>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Media sense commands -->
  <xsl:template match="z:bar-sense |
		       z:gap-sense">
    <xsl:call-template name="command"/>
    <xsl:if test="@level">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@level"/>
    </xsl:if>
    <xsl:call-template name="crlf"/>
  </xsl:template>

</xsl:stylesheet>
