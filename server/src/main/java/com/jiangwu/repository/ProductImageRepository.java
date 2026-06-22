package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.ProductImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface ProductImageRepository extends BaseMapper<ProductImage> {

    @Select("SELECT * FROM t_product_image WHERE product_id = #{productId} ORDER BY sort_order ASC")
    List<ProductImage> findByProductId(Long productId);

    @Select("SELECT image_url FROM t_product_image WHERE product_id = #{productId} ORDER BY sort_order ASC")
    List<String> findImageUrlsByProductId(Long productId);

    @Select("SELECT product_id, image_url FROM t_product_image WHERE product_id IN " +
            "<foreach collection='productIds' item='id' open='(' separator=',' close=')'>#{id}</foreach> " +
            "ORDER BY product_id, sort_order ASC")
    List<Map<String, Object>> findImageUrlsByProductIds(@org.apache.ibatis.annotations.Param("productIds") List<Long> productIds);
}
