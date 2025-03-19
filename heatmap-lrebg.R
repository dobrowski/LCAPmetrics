


for (i in unique(pivot.join.comp$districtname)) {
    

pivot.join.comp %>%
    filter(str_detect(districtname, i)) %>%
    ggplot( aes(x = name , y = fct_rev(studentgroup.long), fill = rate, label = labll)) +
    geom_tile() +
    geom_text(color = "grey70") +
    scale_fill_gradient2(low = "white", high = "red", mid = "pink",
                         #       midpoint = median(df$rate, na.rm = TRUE),
                         limit = c(0,1),
                         space = "Lab",
                         name="Rate") +
    theme_minimal() +
    theme(axis.text.x = element_text(hjust = 1)) +
    labs(title = "Heatmap of Student Groups in Low or Very Low Status",
         subtitle = i,
         x = "",
         y = "")
    
    ggsave(here("output","lrebg-heat", paste0(i,"studentgroup heatmap.png")), width = 8, height = 4.5)

}




for (i in unique(pivot.join.comp.school$districtname)) {
    
    
    pivot.join.comp.school %>%
        filter(str_detect(districtname, i)) %>%
        ggplot( aes(x = name , y = fct_rev(schoolname), fill = rate, label = labll)) +
        geom_tile() +
        geom_text(color = "grey70") +
        scale_fill_gradient2(low = "white", high = "red", mid = "pink",
                             #       midpoint = median(df$rate, na.rm = TRUE),
                             limit = c(0,1),
                             space = "Lab",
                             name="Rate") +
        theme_minimal() +
        theme(axis.text.x = element_text(hjust = 1)) +
        labs(title = "Heatmap of Schools with Low or Very Low Status",
             subtitle = i,
             x = "",
             y = "")
    
    ggsave(here("output","lrebg-heat", paste0(i," schools heatmap.png")), width = 8, height = 4.5)
    
}
