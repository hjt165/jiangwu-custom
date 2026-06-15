package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.ProductImage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ProductImageRepository extends BaseMapper<ProductImage> {

    @Select("SELECT * FROM t_product_image WHERE product_id = #{productId} ORDER BY sort_order ASC")
    List<ProductImage> findByProductId(Long productId);

    @Select("SELECT image_url FROM t_product_image WHERE product_id = #{productId} ORDER BY sort_order ASC")
    List<String> findImageUrlsByProductId(Long productId);
}
