<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xpath-default-namespace="http://www.liquibase.org/xml/ns/dbchangelog">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <!-- MCH CORE -->
    <xsl:variable name="coreTables"
                  select="('TABLE1')"/>

    <xsl:template match="node()[not(self::*)]">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="changeSet" mode="legacy">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="context">legacy</xsl:attribute>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="databaseChangeLog">
        <!-- CORE-->
        <xsl:comment>CORE TABLES</xsl:comment>
        <xsl:variable name="coreTablesVariable" select="changeSet[createTable/@tableName=$coreTables]"/>
        <xsl:comment>CORE SEQUENCES</xsl:comment>
        <xsl:variable name="coreSequencesVariable"
                      select="changeSet[createSequence[starts-with(@sequenceName, 'SEQ_') and substring-after(@sequenceName, 'SEQ_') = $coreTables]]"/>
        <xsl:comment>CORE INDEXES</xsl:comment>
        <xsl:variable name="coreIndexesVariable" select="changeSet[createIndex/@tableName=$coreTables]"/>
        <xsl:comment>CORE FOREIGN CONSTRAINTS</xsl:comment>
        <xsl:variable name="coreForeignConstraintsVariable" select="changeSet[addForeignKeyConstraint/@baseTableName=$coreTables]"/>
        <xsl:comment>CORE VIEWS</xsl:comment>
        <xsl:variable name="coreViewsVariable" select="changeSet[createView/@viewName=$coreTables]"/>
        <xsl:call-template name="createChangeLog">
            <xsl:with-param name="outputFile" select="'core-changelog.xml'"/>
            <xsl:with-param name="changeLogContent"
                            select="$coreTablesVariable,$coreSequencesVariable,$coreIndexesVariable,$coreForeignConstraintsVariable,$coreViewsVariable"/>
        </xsl:call-template>




        <xsl:comment>UNMATCHED</xsl:comment>
        <xsl:variable name="unmatchedChangeSets"
                      select="changeSet[not(some $set in (
                    $coreTablesVariable |
                    $coreSequencesVariable |
                    $coreIndexesVariable |
                    $coreForeignConstraintsVariable |
                    $coreViewsVariable
                ) satisfies $set is .)]"/>
        <xsl:apply-templates select="$unmatchedChangeSets"/>
        <xsl:call-template name="createChangeLog">
            <xsl:with-param name="outputFile" select="'unmatched-changes-changelog.xml'"/>
            <xsl:with-param name="changeLogContent">
                <xsl:apply-templates select="$unmatchedChangeSets"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="createChangeLog">
        <xsl:param name="outputFile"/>
        <xsl:param name="changeLogContent"/>
        <xsl:result-document encoding="UTF-8" indent="true" method="xml" href="{$outputFile}">
            <databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
                               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                               xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                               http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.6.xsd
                               http://www.liquibase.org/xml/ns/dbchangelog" logicalFilePath="TODO">
                <xsl:apply-templates select="$changeLogContent" mode="legacy"/>
                <!--<xsl:copy-of select="$changeLogContent" />-->
            </databaseChangeLog>
        </xsl:result-document>
    </xsl:template>

</xsl:transform>