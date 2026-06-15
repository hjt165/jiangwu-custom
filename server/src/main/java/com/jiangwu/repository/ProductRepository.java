package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Product;
import com.jiangwu.enums.ProductCategory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface ProductRepository extends BaseMapper<Product> {

    @Select("SELECT * FROM t_product WHERE id = #{id} AND deleted = 0")
    Product findById(Long id);

    @Select("SELECT * FROM t_product WHERE artisan_id = #{artisanId} AND deleted = 0 ORDER BY created_at DESC")
    List<Product> findByArtisanId(Long artisanId);

    @Select("SELECT * FROM t_product WHERE category = #{category} AND is_available = 1 AND deleted = 0 ORDER BY created_at DESC")
    List<Product> findByCategory(ProductCategory category);

    @Select("SELECT * FROM t_product WHERE is_featured = 1 AND is_available = 1 AND deleted = 0 ORDER BY created_at DESC")
    List<Product> findFeatured();

    @Select("SELECT * FROM t_product WHERE deleted = 0 AND (title LIKE CONCAT('%', #{keyword}, '%') OR description LIKE CONCAT('%', #{keyword}, '%')) ORDER BY created_at DESC")
    List<Product> search(String keyword);

    @Update("UPDATE t_product SET view_count = view_count + 1, updated_at = NOW() WHERE id = #{id}")
    int incrementViewCount(Long id);

    @Update("UPDATE t_product SET like_count = like_count + #{delta}, updated_at = NOW() WHERE id = #{id}")
    int updateLikeCount(Long id, int delta);

    @Update("UPDATE t_product SET order_count = order_count + 1, updated_at = NOW() WHERE id = #{id}")
    int incrementOrderCount(Long id);

    @Update("UPDATE t_product SET rating = #{rating}, updated_at = NOW() WHERE id = #{id}")
    int updateRating(Long id, BigDecimal rating);
}
