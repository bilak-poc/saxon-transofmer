package com.github.bilakpoc.saxonxslttransformer;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Templates;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import net.sf.saxon.jaxp.SaxonTransformerFactory;

/**
 * @author Lukáš Vasek
 */
@Component
public class SaxonTransformationProcessor implements CommandLineRunner {

    @Value("${transformer.defaultTemplate}")
    private Resource defaultTemplate;
    @Value("${transformer.defaultSourceChangelog}")
    private Resource defaultSourceChangelog;

    @Override
    public void run(final String... args) throws Exception {

        SaxonTransformerFactory transformerFactory = new net.sf.saxon.TransformerFactoryImpl();
        Templates template = getTemplate(defaultTemplate, transformerFactory);
        TransformerHandler mainTemplateTransformerHandler = transformerFactory.newTransformerHandler(template);
        mainTemplateTransformerHandler.setResult(new StreamResult(System.out));
        mainTemplateTransformerHandler.getTransformer().setOutputProperty(OutputKeys.INDENT, "yes");

        try (InputStream is = defaultSourceChangelog.getInputStream()) {
            transformerFactory.newTransformer().transform(new StreamSource(is), new SAXResult(mainTemplateTransformerHandler));
        }
    }

    private static Templates getTemplate(Resource template, TransformerFactory transformerFactory) throws IOException,
            TransformerConfigurationException {
        try (InputStreamReader reader = new InputStreamReader(template.getInputStream())) {
            return transformerFactory.newTemplates(new StreamSource(reader));
        }
    }
}
