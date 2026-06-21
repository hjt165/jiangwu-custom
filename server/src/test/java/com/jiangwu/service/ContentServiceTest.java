package com.jiangwu.service;

import com.jiangwu.entity.ProductImage;
import com.jiangwu.entity.Review;
import com.jiangwu.entity.User;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ContentServiceTest {

    @Mock private ProductImageRepository imageRepository;
    @Mock private ReviewRepository reviewRepository;
    @Mock private UserRepository userRepository;
    @InjectMocks private ContentService contentService;

    @Test
    void getImageReviewList_ReturnsPagedResult() {
        ProductImage image = new ProductImage();
        image.setId(1L);
        image.setImageUrl("http://img.jpg");
        image.setDescription("测试图片");
        image.setReviewStatus(0);
        when(imageRepository.selectCount(any())).thenReturn(1L);
        when(imageRepository.selectList(any())).thenReturn(List.of(image));

        Map<String, Object> result = contentService.getImageReviewList(null, null, 1, 10);
        assertNotNull(result);
        assertEquals(1L, result.get("total"));
        assertNotNull(result.get("list"));
    }

    @Test
    void getImageReviewList_WithKeyword() {
        when(imageRepository.selectCount(any())).thenReturn(0L);
        when(imageRepository.selectList(any())).thenReturn(List.of());

        Map<String, Object> result = contentService.getImageReviewList("测试", null, 1, 10);
        assertNotNull(result);
    }

    @Test
    void reviewImage_Pass() {
        ProductImage image = new ProductImage();
        image.setId(1L);
        image.setReviewStatus(0);
        when(imageRepository.selectById(1L)).thenReturn(image);
        doReturn(1).when(imageRepository).updateById(any(ProductImage.class));

        contentService.reviewImage(1L, "pass", "通过", 1L);
        verify(imageRepository).updateById(any(ProductImage.class));
    }

    @Test
    void reviewImage_Reject() {
        ProductImage image = new ProductImage();
        image.setId(1L);
        when(imageRepository.selectById(1L)).thenReturn(image);
        doReturn(1).when(imageRepository).updateById(any(ProductImage.class));

        contentService.reviewImage(1L, "reject", "不符合", 1L);
        verify(imageRepository).updateById(any(ProductImage.class));
    }

    @Test
    void reviewImage_NotFound_ThrowsException() {
        when(imageRepository.selectById(999L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> contentService.reviewImage(999L, "pass", null, 1L));
    }

    @Test
    void batchReviewImages_ProcessesAll() {
        ProductImage img1 = new ProductImage();
        img1.setId(1L);
        ProductImage img2 = new ProductImage();
        img2.setId(2L);
        when(imageRepository.selectById(1L)).thenReturn(img1);
        when(imageRepository.selectById(2L)).thenReturn(img2);
        doReturn(1).when(imageRepository).updateById(any(ProductImage.class));

        contentService.batchReviewImages(List.of(1L, 2L), "pass", "批量通过", 1L);
        verify(imageRepository, times(2)).updateById(any(ProductImage.class));
    }

    @Test
    void getCommentReviewList_ReturnsPagedResult() {
        Review review = new Review();
        review.setId(1L);
        review.setRating(5);
        review.setContent("很好");
        review.setUserId(1L);
        when(reviewRepository.selectCount(any())).thenReturn(1L);
        when(reviewRepository.selectList(any())).thenReturn(List.of(review));
        when(userRepository.selectById(1L)).thenReturn(new User());

        Map<String, Object> result = contentService.getCommentReviewList(null, null, null, null, 1, 10);
        assertNotNull(result);
        assertEquals(1L, result.get("total"));
    }

    @Test
    void reviewComment_Pass() {
        Review review = new Review();
        review.setId(1L);
        when(reviewRepository.selectById(1L)).thenReturn(review);
        doReturn(1).when(reviewRepository).updateById(any(Review.class));

        contentService.reviewComment(1L, "pass", "好评", 1L);
        verify(reviewRepository).updateById(any(Review.class));
    }

    @Test
    void reviewComment_NotFound_ThrowsException() {
        when(reviewRepository.selectById(999L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> contentService.reviewComment(999L, "pass", null, 1L));
    }

    @Test
    void batchReviewComments_ProcessesAll() {
        Review r1 = new Review();
        r1.setId(1L);
        Review r2 = new Review();
        r2.setId(2L);
        when(reviewRepository.selectById(1L)).thenReturn(r1);
        when(reviewRepository.selectById(2L)).thenReturn(r2);
        doReturn(1).when(reviewRepository).updateById(any(Review.class));

        contentService.batchReviewComments(List.of(1L, 2L), "reject", "违规", 1L);
        verify(reviewRepository, times(2)).updateById(any(Review.class));
    }
}
