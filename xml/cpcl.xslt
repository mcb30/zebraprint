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

  <!-- Fail on unknown elements -->
  <xsl:template match="*">
    <xsl:message terminate="yes">Unrecognised element:
    <xsl:value-of select="local-name()"/>
    </xsl:message>
  </xsl:template>

  <!-- Raw data (including multiline items) -->
  <xsl:template match="z:raw |
		       z:item">
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Zero parameter commands -->
  <xsl:template match="z:form |
		       z:journal |
		       z:in-inches |
		       z:in-centimeters |
		       z:in-millimeters |
		       z:in-dots |
		       z:center |
		       z:left |
		       z:right |
		       z:pace |
		       z:auto-pace |
		       z:no-pace |
		       z:rewind-off |
		       z:rewind-on |
		       z:cut |
		       z:partial-cut">
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
		       z:pw |
		       z:wait |
		       z:pre-tension |
		       z:post-tension |
		       z:speed |
		       z:setsp |
		       z:underline |
		       z:on-feed |
		       z:prefeed |
		       z:postfeed |
		       z:country |
		       z:beep |
		       z:cut-at">
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
  </xsl:template>

  <!-- Line drawing commands:

       {command} {x0} {y0} {x1} {y1} {width}
  -->
  <xsl:template match="z:box |
		       z:line |
		       z:inverse-line">
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

</xsl:stylesheet>
