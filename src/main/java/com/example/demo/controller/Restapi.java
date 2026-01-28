package com.example.demo.controller;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Restapi {

    @GetMapping("/hello")
    public String hello() {
        return "Hello World";
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }


    @GetMapping("/")
    public String redirect() {
    return "Hello World";
    }

}


