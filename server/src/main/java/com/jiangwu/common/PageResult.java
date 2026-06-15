package com.jiangwu.common;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.util.List;

/**
 * 分页响应封装
 */
@Data
public class PageResult<T> {

    /** 总记录数 */
    private long total;

    /** 当前页数据 */
    private List<T> records;

    /** 当前页码 */
    private long current;

    /** 每页大小 */
    private long size;

    /** 总页数 */
    private long pages;

    public PageResult() {}

    public PageResult(long total, List<T> records, long current, long size, long pages) {
        this.total = total;
        this.records = records;
        this.current = current;
        this.size = size;
        this.pages = pages;
    }

    /**
     * 从 MyBatis-Plus IPage 转换
     */
    public static <T> PageResult<T> from(IPage<T> page) {
        return new PageResult<>(
                page.getTotal(),
                page.getRecords(),
                page.getCurrent(),
                page.getSize(),
                page.getPages()
        );
    }
}
