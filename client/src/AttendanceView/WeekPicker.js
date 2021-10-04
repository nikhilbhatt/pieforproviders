import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'
import { LeftOutlined, RightOutlined } from '@ant-design/icons'

export function WeekPicker({
  dateSelected,
  handleDateChange,
  hasPrev = true,
  hasNext = true
}) {
  return (
    <div>
      <Button
        disabled={!hasPrev}
        onClick={() => handleDateChange(dateSelected.weekday(-7))}
        data-cy="backWeekButton"
      >
        <LeftOutlined />
      </Button>
      <Button
        className="mx-2"
        style={{
          color: '#1b82ab',
          borderColor: '#1b82ab'
        }}
      >
        {dateSelected.weekday(0).format('MMM D') +
          ' - ' +
          dateSelected.weekday(6).format('MMM D, YYYY')}
      </Button>
      <Button
        disabled={!hasNext}
        onClick={() => handleDateChange(dateSelected.weekday(7))}
        data-cy="forwardWeekButton"
      >
        <RightOutlined />
      </Button>
    </div>
  )
}

WeekPicker.propTypes = {
  dateSelected: PropTypes.object,
  handleDateChange: PropTypes.func,
  hasPrev: PropTypes.bool,
  hasNext: PropTypes.bool
}
